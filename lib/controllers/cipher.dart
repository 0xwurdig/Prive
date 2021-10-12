// import 'package:encrypt/encrypt.dart';

// encrypt({
//   String text,
//   String org,
//   String name,
// }) {
//   final plainText = text;
//   final key = Key.fromUtf8("1E75B2D45EGARG748FF41POW8EGHEAFS");
//   final iv = IV.fromSecureRandom(8);
//   final encrypter = Encrypter(Salsa20(key));
//   final encrypted = encrypter.encrypt(plainText, iv: iv);
//   // final decrypted = encrypter.decrypt(Encrypted.from64(encrypted.base64),
//   //     iv: iv);

//   // print(decrypted);
//   Map msg = {
//     "body": text.text,
//     "sent": FieldValue.serverTimestamp(),
//     "type": "txt",
//     "from": name
//   };
//   return msg;
// }
