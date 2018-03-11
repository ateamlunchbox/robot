#!/usr/bin/env groovy
//
// Listen for gRPC requests to the RubyRobot, and forward them
// on to another RubyRobot gRPC server.  This can be used
// proxy requests from a Ruby client -> this Java proxy ->
// a Ruby server, and then back again.
// 
// I wanted to be able to test gRPC with Ruby clients calling a 
// Java server, and vice versa.
//

import net.avilla.netflix.studio.robot.*;

import java.util.concurrent.TimeUnit;

import io.grpc.ManagedChannel;
import io.grpc.StatusRuntimeException;
import io.grpc.ManagedChannelBuilder;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;
import java.io.IOException;

import com.google.protobuf.Empty;

public class RubyRobotClient {

  private final ManagedChannel channel;
  private final RubyRobotGrpc.RubyRobotBlockingStub blockingStub;

  public RubyRobotClient(String host, int port) {
    channel = ManagedChannelBuilder.forAddress(host, port)
      .usePlaintext(true)
      .build();
    blockingStub = RubyRobotGrpc.newBlockingStub(channel);
  }

  public void shutdown() throws InterruptedException {
    channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
  }

  public RubyRobotResponse report(com.google.protobuf.Empty arg) {
    RubyRobotResponse response = null;
    try {
      response = blockingStub.report(arg);
      return response;
    } catch (StatusRuntimeException e) {
      System.err.println("Error calling #report: " + e);
    }
    return response;
  }
}

public class RubyRobotServer {
  private Server server;

  private void start() throws IOException {
    /* The port on which the server should run */
    int port = 31311;
    server = ServerBuilder.forPort(port)
        .addService(new RubyRobotImpl())
        .build()
        .start();
    System.out.println("Server started, listening on " + port);
    Runtime.getRuntime().addShutdownHook(new Thread() {
      @Override
      public void run() {
        // Use stderr here since the logger may have been reset by its JVM shutdown hook.
        System.err.println("*** shutting down gRPC server since JVM is shutting down");
        RubyRobotServer.this.stop();
        System.err.println("*** server shut down");
      }
    });
  }

  private void stop() {
    if (server != null) {
      server.shutdown();
    }
  }

  /**
   * Await termination on the main thread since the grpc library uses daemon threads.
   */
  private void blockUntilShutdown() throws InterruptedException {
    if (server != null) {
      server.awaitTermination();
    }
  }

  /**
   * Main launches the server from the command line.
   */
  public static void main(String[] args) throws IOException, InterruptedException {
    final RubyRobotServer server = new RubyRobotServer();
    server.start();
    server.blockUntilShutdown();
  }

  static class RubyRobotImpl extends RubyRobotGrpc.RubyRobotImplBase {

  private RubyRobotClient client = new RubyRobotClient("127.0.0.1", 31310);
    
    @Override
  public void left(Empty request, StreamObserver<RubyRobotResponse> responseObserver) {
//      responseObserver.onNext(client.left(request));
      // TODO Auto-generated method stub
    super.left(request, responseObserver);
  }

  @Override
  public void move(Empty request, StreamObserver<RubyRobotResponse> responseObserver) {
    // TODO Auto-generated method stub
    super.move(request, responseObserver);
  }

  @Override
  public void place(RubyRobotRequest request, StreamObserver<RubyRobotResponse> responseObserver) {
    // TODO Auto-generated method stub
    super.place(request, responseObserver);
  }

  @Override
  public void remove(Empty request, StreamObserver<Empty> responseObserver) {
    // TODO Auto-generated method stub
    super.remove(request, responseObserver);
  }

  @Override
  public void report(Empty request, StreamObserver<RubyRobotResponse> responseObserver) {
      responseObserver.onNext(client.report(request));
        responseObserver.onCompleted();
    }

  @Override
  public void right(Empty request, StreamObserver<RubyRobotResponse> responseObserver) {
//      responseObserver.onNext(client.right(request));
//      responseObserver.onCompleted();
  }
  }
}

RubyRobotServer s = new RubyRobotServer();
s.start();
s.blockUntilShutdown();

//println "Goodbye world!"
