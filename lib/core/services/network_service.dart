import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class NetworkService {
  final Dio dio;

  NetworkService({Dio? dio}) : dio = dio ?? Dio() {
    _configureDio();
  }

  void _configureDio() {
    dio.options.baseUrl = 'https://api.todoist.com/rest/v2';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] =
            'Bearer 69bd326cfb8c969b3b7d3f711085c0083ad57af0';

        options.headers['X-Request-Id'] = const Uuid().v4();

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }
}
