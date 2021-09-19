FROM golang:latest AS builder
ADD . /app
WORKDIR /app/go-server
RUN go mod download
RUN go get -u github.com/pressly/goose/cmd/goose
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-w" -a -o /main .


#build the react app
FROM node:alpine AS node_builder
COPY --from=builder /app/client .
RUN npm install
RUN npm run build

# alpine image
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /main .
COPY --from=node_builder /build ./web
RUN chmod +x ./main
EXPOSE 8080
CMD ./main
