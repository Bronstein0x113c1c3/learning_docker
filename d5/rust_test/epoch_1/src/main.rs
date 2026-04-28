use std::sync::{Arc, Mutex};

use tokio::{self, sync::mpsc::unbounded_channel};

use rodio::{Decoder, OutputStream, Sink};
#[tokio::main]
async fn main() {
    // use tokio::io::{self, AsyncBufReadExt};

    // let stdin = io::stdin();
    // let mut reader = io::BufReader::new(stdin).lines();

    // println!("Type something and press Enter (Ctrl+D to exit):");

    // while let Ok(Some(line)) = reader.next_line().await {
    //     println!("You typed: {}", line);
    // }

    /* */
    let (stream, stream_handle) = OutputStream::try_default().unwrap();

    // stream.into()
    let sink = Arc::new(Mutex::new(Sink::try_new(&stream_handle).unwrap()));

    let (mut tx, mut rx) = tokio::sync::mpsc::unbounded_channel();
    // Add a oneshot channel for completion notification
    let (complete_tx, complete_rx) = tokio::sync::oneshot::channel();

    let file = std::io::BufReader::new(
        std::fs::File::open("./list_songs/02. Why Why Why.flac").unwrap(),
    );
    let mut source = Decoder::new(file).unwrap();

    // Producer task
    let t = tokio::spawn(async move {
        let buffer: Vec<i16> = source.by_ref().collect();
        let bytes: Vec<u8> = buffer
        .iter()
        .flat_map(|&num| num.to_be_bytes().to_vec())
        .collect();
        let mut iter = bytes.chunks(16384);

        while let Some(res) = iter.next() {
            let mut salt = "music_chunk".as_bytes().to_vec();
            let mut res = res.to_owned();
            res.append(&mut salt);
            tx.send(res);
        }

        // Signal that we've finished sending all data
    });

    // Consumer task
    let s1 = sink.clone();
    let t3 = tokio::spawn(async move {
        while let Some(res) = rx.recv().await {
            println!("receiving chunk...");
            let res: Vec<i16> = res[..res.len() - 11]
            .chunks_exact(2)
            .map(|chunk| i16::from_be_bytes(chunk.try_into().unwrap()))
            .collect();
            let res = rodio::buffer::SamplesBuffer::new(2, 48000, res);
            s1.lock().unwrap().append(res);
        }
        complete_tx.send(()).unwrap();
    });

    // Player wait task
    let t2 = tokio::spawn(async move {
        // Wait for either:
        // 1. The completion signal (all data sent)
        // 2. The consumer task to finish (in case of error)
        tokio::select! {
            _ = complete_rx => {
                println!("All data received, waiting for playback to finish...");
                sink.lock().unwrap().sleep_until_end();
                println!("Playback completed!");
            }
            // _ = t3 => {
            //     println!("Consumer task finished early");
            // }
        }
    });

    // Wait for all tasks to complete
    tokio::try_join!(t, t3, t2).unwrap();
}

// #[tokio::test]
// async fn comparing() {
//     let mut vec1 = Vec::with_capacity(300);
//     let mut vec2 = vec![4, 5, 6, 8];
//
//     {
//         vec1 = vec2;
//     }
//     // (&mut vec1) = vec2;
//     println!("{:?}", vec1.len());
// }
//
// #[tokio::test]
// async fn test_equal() {
//     let test_str = "done".as_bytes().to_vec();
//     assert!(&test_str == "done".as_bytes());
// }
//
// #[tokio::test]
// async fn test_some() {
//     let buffer: Vec<i16> = vec![-1, 34, 56, 23, 32535, 0];
//     let expected: Vec<u8> = vec![255, 255, 0, 34, 0, 56, 0, 23, 127, 23, 0, 0];
//     let bytes: Vec<u8> = buffer
//     .iter()
//     .flat_map(|&num| num.to_be_bytes().to_vec()) // little-endian
//     // .flat_map(|&num| num.to_be_bytes().to_vec()) // big-endian
//     .collect();
//     // assert!(bytes,"{}", expected);
//     for i in 0..expected.len() {
//         assert!(expected[i] == bytes[i], "done!!");
//     }
//     // println!("{:?}", bytes);
//     // println!("{:?}", expected);
// }
//
// #[tokio::test]
//
// async fn test_transferring() {
//     // println!("{}",str);
//     let (stream, stream_handle) = OutputStream::try_default().unwrap();
//
//     let sink = Arc::new(Mutex::new(Sink::try_new(&stream_handle).unwrap()));
//     let (mut tx, mut rx) = tokio::sync::mpsc::unbounded_channel();
//     let t = tokio::spawn(async move {
//         let file = std::io::BufReader::new(
//             std::fs::File::open("./list_songs/02 - Good To Be.flac").unwrap(),
//         );
//         let mut source = Decoder::new(file).unwrap();
//
//         // source.
//         let buffer: Vec<i16> = source.by_ref().collect();
//         // println!("{:?}", &buffer);
//         let bytes: Vec<u8> = buffer
//         .iter()
//         .flat_map(|&num| num.to_be_bytes().to_vec()) // little-endian
//         // .flat_map(|&num| num.to_be_bytes().to_vec()) // big-endian
//         .collect();
//         let mut iter = bytes.chunks(2048); // 1mb per chunk....
//
//         while let Some(res) = iter.next() {
//             tx.send(res.to_owned());
//         }
//     });
//     let s1 = sink.clone();
//
//     let t3 = tokio::spawn(async move {
//         while let Some(res) = rx.recv().await {
//             // socket.send_to(&res, addr).await.unwrap();
//             // println!("the receiver: {:?}",res);
//             // assert!()
//             println!("receiving chunk...");
//             let res: Vec<i16> = res
//             .chunks_exact(2)
//             .map(|chunk| i16::from_be_bytes(chunk.try_into().unwrap()))
//             .collect();
//             let res = rodio::buffer::SamplesBuffer::new(2, 48000, res);
//             s1.lock().unwrap().append(res);
//         }
//     });
//     let t2 = tokio::task::spawn(async move {
//         sink.lock().unwrap().sleep_until_end();
//         println!("waiting is called!!!!");
//         // tokio::task::yield_now().await;
//         println!("now, yield...");
//         println!("the player has been done!!!!")
//     });
//
//     t.await;
//     t2.await;
//     t3.await;
// }
// #[tokio::test]
// async fn test_eq() {
//     let res = "abcxyz".to_string();
//     assert!(&res[..3] != "abc", "they equals");
// }
//
// #[tokio::test]
// async fn test_plus() {
//     let mut i: u8 = 255;
//     i = i + 1;
//     assert!(i == 0);
// }
//
// #[tokio::test]
// async fn test_close() {
//     let (mut tx, mut rx) = unbounded_channel();
//     let t1 = tokio::spawn(async move {
//         while !tx.is_closed() {
//             tx.send(1);
//         }
//         drop(tx);
//     });
//
//     for i in 0..3 {
//         match rx.recv().await {
//             Some(i) => {
//                 println!("{}", i);
//             }
//             None => {}
//         }
//     }
//     rx.close();
//     t1.await;
// }
