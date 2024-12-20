import 'channel.dart';
import 'misc/logger.dart';
import 'misc/piesocket_options.dart';

class PieSocket {
  PieSocket(this.options)
      : assert(options.apiKey.isNotEmpty, 'API Key is should be provided'),
        assert(options.clusterId.isNotEmpty, 'Cluster ID should be provided'),
        logger = Logger(options.enableLogs);

  final Map<String, Channel> rooms = {};
  final Logger logger;
  final PieSocketOptions options;

  Channel join(String roomId, {PieSocketOptions? options}) {
    final opt = options ?? this.options;
    Channel? room = rooms[roomId];
    if (room != null) {
      if (room.options != opt) {
        logger.debug("Option changed for existing room instance: $roomId");
        room.options = opt;
        room.disconnect();
      }

      logger.debug("Returning existing room instance: $roomId");
      return room;
    }

    room = Channel(roomId, opt, logger);
    rooms[roomId] = room;

    return room;
  }

  void leave(String roomId) {
    if (rooms.containsKey(roomId)) {
      logger.debug("DISCONNECT: Closing room connection: $roomId");
      rooms[roomId]?.disconnect();
      rooms.remove(roomId);
    } else {
      logger.debug("DISCONNECT: Room does not exist: $roomId");
    }
  }

  Channel? roomOf(String name) {
    return rooms[name];
  }

  Map<String, Channel> getAllRooms() {
    return {...rooms};
  }

  /// Close all connection
  void closeAll() {
    final rooms = {...this.rooms};
    this.rooms.clear();

    for (final entry in rooms.entries) {
      final roomId = entry.key;
      final room = entry.value;

      logger.debug("DISCONNECT: Closing room connection: $roomId");
      room.disconnect();
    }
  }
}
