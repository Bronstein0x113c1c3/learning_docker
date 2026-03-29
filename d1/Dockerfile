# Giai đoạn 1: Build binary
FROM golang:latest as builder

# Thiết lập thư mục làm việc cụ thể
WORKDIR /app

# Copy các file dependency và code
COPY go.mod ./
# Nếu bạn có file go.sum, hãy copy cả nó: COPY go.mod go.sum ./
COPY main.go ./

# BUILD QUAN TRỌNG:
# 1. CGO_ENABLED=0 để tạo static binary (chạy được trên scratch)
# 2. GOOS=linux đảm bảo build cho đúng hệ điều hành container
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Giai đoạn 2: Tạo image siêu nhỏ
FROM scratch

# Thiết lập thư mục làm việc (tùy chọn)
WORKDIR /

# Copy binary từ stage builder sang stage scratch bằng đường dẫn tuyệt đối
COPY --from=builder /app/main /main

# Chạy binary
ENTRYPOINT ["/main"]
