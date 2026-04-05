FROM golang as builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
COPY sound ./sound
RUN apt-get update
RUN apt-get -y install alsa-tools libasound2-dev build-essential
RUN go mod tidy &&  go build -o main


FROM ubuntu
COPY --from=builder /app/main .
RUN apt-get update
RUN apt-get -y install libasound2-dev
ENTRYPOINT [ "./main" ]

