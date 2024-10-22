typedef ErrorCallback = void Function(Object error, StackTrace stackTrace);

typedef EventHandler = dynamic Function(dynamic);

typedef EventCallback<T extends dynamic> = void Function(T data);

typedef ValueChanged<P> = void Function(P value);
