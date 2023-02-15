import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import './AllEnum.dart';
import 'global.dart' as global;

class DataLogic {
  List<Uint8List> dataFromBlu = List.empty(growable: true);
  Transport transport = Transport();
  List<Uint8List> buffer = List.empty(growable: true);
  Uint8List localBuffer = Uint8List(20);
  List<int> answerForSend = List.empty(growable: true),
      listSendId = List.empty(growable: true);
  List<bool> listSendBool = List.empty(growable: true);

  void parseDataFromBLU() {
    if (dataFromBlu.length != buffer) {
      buffer.add(dataFromBlu.last);
      transport.receive(buffer.last);
      if (!transport.packet.isRepetition(transport.packet)) {
        if (transport.makeAcknowledge) {
          Packet p = transport.packet.getAcknowledge(transport.sender!,
              transport.recipient!, transport.id, transport.type!);
          localBuffer = p.headerToList(p.header);
        }
        print(transport.sender);
        buffer.clear();
      } else {
        print('Retrans');
        localBuffer = new Uint8List(0);
      }
    }
  }

  Uint8List makeAcknowledgeForSend() {
    if (transport.makeAcknowledge) {
      transport.makeAcknowledge = false;
    }
    return localBuffer;
  }

  List<int> makePackage(int num, PacketTypeEnum type, List<int> data) {
    answerForSend = [];
    Packet packet = Packet();
    packet.prepare(type.index, Packet.SRTD_ADDR, num, data);
    answerForSend.addAll(packet.headerToList(packet.header) + data);
    return answerForSend;
  }

  List<int> makeTestPack(int num) {
    answerForSend = [];
    Packet packet = Packet();
    packet
        .prepare(PacketTypeEnum.GET_TIME.index, Packet.SRTD_ADDR, num, []);
    answerForSend.addAll(packet.headerToList(packet.header));
    listSendId.add(packet.header.id);
    listSendBool.add(false);
    return answerForSend;
  }

  List<int> packForMap() {
    return transport.listSenders;
  }
}

class PacketHolder {
  Packet? packet;
  int? applicant;
  ePacketStates? state;
  DateTime? createTime;
  int? priority;
  int tries = 5;
  int? resendTimeSec;
  int? elapsedTime;
  Stream? dataHolder;
  int? position;
  int? size;
}

class Transport {
  Packet packet = new Packet();
  List<int> buf = List.empty(growable: true),
      listSenders = List.empty(growable: true),
      alarmList = List.empty(growable: true);
  int ownAddress = Packet.SRTD_ADDR;
  int pos = 0, counter = 0, id = 1;
  int? recipient, sender, type;
  ReceiverStateEnum state = ReceiverStateEnum.markerWaitingState;
  bool makeAcknowledge = false;
  List<PacketHolder> queue = [];
  Random random = Random();

  static const int USER_PRIORITY = 0;
  static const int RESEND_PRIORITY = 1;
  static const int INTERROGATOR_PRIORITY = 2;
  static const int USER_REPEAT_TRIES = 5;

  void receive(List<int> data) {
    //pos += data.length;
    buf.addAll(data);
    while (true) {
      if (state == ReceiverStateEnum.markerWaitingState) {
        for (int i = 0; i < buf.length - 1; i++) {
          if (buf[i] == 173 && buf[i + 1] == 222) {
            if (i > 0) {
              buf.removeRange(0, i);
              counter = i;
            }
            state = ReceiverStateEnum.headerWaitingState;
            break;
          }
        }
      }
      if (state == ReceiverStateEnum.headerWaitingState) {
        if (buf.length >= Packet.HEADER_SIZE) {
          packet.getHeaderFromBinary(Uint8List.fromList(buf));
          state = ReceiverStateEnum.dataWaitingState;
        } else {
          break;
        }
      }
      if (state == ReceiverStateEnum.dataWaitingState) {
        if (packet.header.size > buf.length) {
          break;
        } else {
          if (packet.header.size == Packet.HEADER_SIZE) {
            packet.addData([]);
          } else {
            int size = packet.header.size - Packet.HEADER_SIZE;
            //print(size);
          }
          packet.addData(buf);
          buf.removeRange(0, Packet.HEADER_SIZE);
          if (packet.isPacketValid()) {
            buf = [];
            sender = packet.header.sender;
            recipient = packet.header.recipient;
            id = packet.header.id;
            type = packet.header.type;
            if (type == PacketTypeEnum.ALARM.index ||
                type == PacketTypeEnum.PHOTO.index ||
                type == PacketTypeEnum.SEISMIC_WAVE.index ||
                type == PacketTypeEnum.MESSAGE.index) {
              if (type == PacketTypeEnum.ALARM.index) {
                alarmList.add(sender!);
              }
              makeAcknowledge = true;
              print(sender);
            }
            if (listSenders.length == 0) {
              listSenders.add(sender!);
            }
            for (int i = 0; i < listSenders.length; i++) {
              if (listSenders[i] == sender) {
                break;
              }
              if (i + 1 == listSenders.length) {
                listSenders.add(sender!);
              }
            }
            print(listSenders);

            state = ReceiverStateEnum.markerWaitingState;
            break;
          } else {
            print('delete');
            buf.removeRange(0, 2);
            state = ReceiverStateEnum.markerWaitingState;
          }
        }
      }
    }
  }

  int checkColor(int num) {
    int index = -1;
    print(sender);
    if (sender == num) {
      index = sender!;
    }
    return index;
  }

  void interrogator() {}

  PacketHolder preparePacketHolder(Packet p, int priority, int applicant) {
    PacketHolder ph = PacketHolder();
    ph.applicant = applicant;
    ph.createTime = DateTime(1, 1, 1, 1, 1);
    ph.packet = p;
    ph.state = ePacketStates.PACKET_READY_TO_SEND;
    ph.priority = priority;
    ph.dataHolder = null;
    ph.tries = USER_REPEAT_TRIES;
    ph.elapsedTime = 0;
    ph.resendTimeSec = random.nextInt(2) + 2;
    return ph;
  }

  void processQueue() {
    if (queue.isEmpty) {
      return;
    }
    PacketHolder ph;
    List<PacketHolder> forSend = [];

    for (int i = queue.length - 1; i >= 0; i--) {
      PacketHolder item = queue[i];
      ph = item;
      ph.elapsedTime = ph.elapsedTime! + 1;

      if (ph.state == ePacketStates.PACKET_READY_TO_SEND) {
        forSend.add(ph);
        ph.state = ePacketStates.PACKET_ON_PROCESS;
      } else if (ph.elapsedTime! >= ph.resendTimeSec!) {
        ph.elapsedTime = 0;
        if (--ph.tries == 0) {
          queue.remove(item);
          //onError;
        } else {
          forSend.add(ph);
          ph.priority = RESEND_PRIORITY;
        }
      }
    }

    int prioroty = 0;
    while (true) {
      if (forSend.isEmpty) {
        return;
      }
      if (prioroty > 10) return;

      for (int i = forSend.length - 1; i >= 0; i--) {
        PacketHolder item = forSend[i];
        if (prioroty == item.priority) {
          //send in blu
          forSend.remove(item);
        }
      }
      prioroty++;
    }
  }

  int getParameters(Packet p, int applicant) {
    if (queue.length == Packet.MAX_QUEUE_SIZE) {
      return 0;
    }
    p.responseType == p.header.type - 1;
    queue.add(preparePacketHolder(p, USER_PRIORITY, applicant));
    processQueue();
    return 1;
  }

  int setParameters(Packet p, int applicant) {
    if (queue.length == Packet.MAX_QUEUE_SIZE) {
      return 0;
    }
    queue.add(preparePacketHolder(p, USER_PRIORITY, applicant));
    return 1;
  }

  int getMedia(Packet p, int responseType, Stream dataHolder, int applicant) {
    if (queue.length == Packet.MAX_QUEUE_SIZE) {
      return 0;
    }
    p.responseType = responseType;
    PacketHolder ph = preparePacketHolder(p, USER_PRIORITY, applicant);
    ph.dataHolder = dataHolder;
    queue.add(ph);
    processQueue();
    return 1;
  }

/*  String getError(){
    return
  }*/
}

class Header {
  int name = 0;
  int id = 0;
  int size = 0;
  int type = 0;
  int recipient = 0;
  int sender = 0;
  int hops1 = 0;
  int hops2 = 0;
  int hops3 = 0;
  int hops4 = 0;
  int hops5 = 0;
  int hops6 = 0;
  int hops7 = 0;
  int hops8 = 0;
  int crc16 = 0;
}

class Packet {
  Header header = Header();
  List<int> data = List<int>.empty(growable: true);
  int? responseType;
  int? lastID, lastSender;
  int incr = 0;
  int id = 1;
  //int sizeOfHeader = 20;

  static const int ARRAY_MAX_SIZE = 140;
  static const int HEADER_SIZE = 20;
  static const int SRTD_ADDR = 998;
  static const int BROADCAST_ADDR = 999;
  static const int PORT_NO = 20108;
  static const int MAX_QUEUE_SIZE = 20;

  Header getHeaderFromBinary(Uint8List data) {
    incr = 0;
    Header header = Header();
    header.name = readTwoByte(data);
    header.id = readTwoByte(data);
    header.size = readOneByte(data);
    header.type = readOneByte(data);
    header.recipient = readTwoByte(data);
    header.sender = readTwoByte(data);
    header.hops1 = readOneByte(data);
    header.hops2 = readOneByte(data);
    header.hops3 = readOneByte(data);
    header.hops4 = readOneByte(data);
    header.hops5 = readOneByte(data);
    header.hops6 = readOneByte(data);
    header.hops7 = readOneByte(data);
    header.hops8 = readOneByte(data);
    header.crc16 = readTwoByte(data);

    this.header = header;

    return header;
  }

  int readOneByte(Uint8List data) {
    incr++;
    return (data[incr - 1]);
  }

  int readTwoByte(Uint8List data) {
    incr += 2;
    return ((data[incr - 2] + data[incr - 1] * 256));
  }

  Uint8List headerToList(Header h) {
    Uint8List arr = Uint8List(HEADER_SIZE);
    arr[0] = hToListOst(h.name);
    arr[1] = hToListCel(h.name);
    arr[2] = hToListOst(h.id);
    arr[3] = hToListCel(h.id);
    arr[4] = h.size;
    arr[5] = h.type;
    arr[6] = hToListOst(h.recipient);
    arr[7] = hToListCel(h.recipient);
    arr[8] = hToListOst(h.sender);
    arr[9] = hToListCel(h.sender);
    arr[10] = h.hops1;
    arr[11] = h.hops2;
    arr[12] = h.hops3;
    arr[13] = h.hops4;
    arr[14] = h.hops5;
    arr[15] = h.hops6;
    arr[16] = h.hops7;
    arr[17] = h.hops8;
    arr[18] = hToListOst(h.crc16);
    arr[19] = hToListCel(h.crc16);
    return arr;
  }

  int hToListCel(int num) {
    return (num ~/ 256);
  }

  int hToListOst(int num) {
    return (num % 256);
  }

  Uint8List addOneByte(Uint8List data, int value) {
    data.add(value);
    return data;
  }

  Uint8List addTwoByte(Uint8List data, int value) {
    data.add((value) ~/ 256);
    data.add((value) % 256);
    return data;
  }

  Packet addData(List<int> data) {
    this.data = data;
    return this;
  }

  void prepareHeader(int type, int sender, int recipient, int size, int id) {
    header.name = 57005;
    header.id = id;
    header.size = (size + HEADER_SIZE);
    header.type = type;
    header.recipient = recipient;
    header.sender = sender;
    header.hops1 = 0;
    header.hops2 = 0;
    header.hops3 = 0;
    header.hops4 = 0;
    header.hops5 = 0;
    header.hops6 = 0;
    header.hops7 = 0;
    header.hops8 = 0;
    header.crc16 = 0;
  }

  Packet prepare(int type, int sender, int recipient, List<int> data) {
    prepareHeader(type, sender, recipient, data.length, getNewID());
    header.crc16 = calcCRC(header, data);
    return this;
  }

  int calcCRC(Header h, List<int> data) {
    List<int> d = objectToByteArray(h, data);
    int crc = 65535;
    int b;

    for (int j = 0; j < d.length; j++) {
      b = d[j];
      crc ^= (b << 8);
      crc &= 65535;
      for (int i = 0; i < 8; i++) {
        crc = ((crc & 32768) != 0) ? ((crc << 1) ^ 32773) : (crc << 1);
        crc &= 65535;
      }
    }
    return crc;
  }

  int prepareAcknowledge(int id) {
    print(id);
    return (id ^ 65535);
  }

  Packet getAcknowledge(int sender, int recipient, int id, int type) {
    Packet p = new Packet();
    p.prepareHeader(
        type, recipient, sender, p.data.length, prepareAcknowledge(id));
    p.addData(Uint8List(0));
    p.header.crc16 = calcCRC(p.header, p.data);
    return p;
  }

  List<int> objectToByteArray(Header obj, List<int> obj2) {
    Uint8List headerList = headerToList(obj);
    Uint8List arr = new Uint8List(obj2.length + HEADER_SIZE);

    if (obj != null && obj2 != null) {
      for (int i = 0; i < arr.length - 1; i++) {
        if (i < HEADER_SIZE) {
          arr[i] = headerList[i];
          continue;
        } else {
          arr[i] = obj2[i - headerList.length];
        }
      }
    }
    return arr;
  }

  int getNewID() {
    print(id);
    return (++id & 32767);
  }

  List<int> getBinary() {
    return objectToByteArray(header, data);
  }

  Object getObjectFromBinary(Object obj, int size) {
    return obj;
  }

  int getDataSize() {
    return (header.size - HEADER_SIZE);
  }

  bool isPacketValid() {
    int tmp = header.crc16;
    header.crc16 = 0;
    bool valid = (tmp == calcCRC(header, data));
    header.crc16 = tmp;
    return valid;
  }

  bool isAcknowlidge(Packet p) {
    return ((header.id ^ 65536) == p.header.id) &&
        (header.type == p.header.type) &&
        (header.sender == p.header.recipient) &&
        (header.recipient == p.header.sender);
  }

  bool isResponse(Packet p) {
    return (responseType == p.header.type) &&
        (header.sender == p.header.recipient) &&
        (header.recipient == p.header.sender);
  }

  bool isRepetition(Packet p) {
    if (lastID == p.header.id && lastSender == p.header.sender) {
      return true;
    } else {
      lastSender = p.header.sender;
      lastID = p.header.id;
      return false;
    }
  }
}
