import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:injectable/injectable.dart';

@Named('contactBook')
@LazySingleton(as: ContactBook, env: ['REMOTE_HTTP', 'REMOTE_DIO'])
class ContactBookRemote implements ContactBook {

  ContactBookRemote(
      @Named("contacts") this.contacts,
      @Named("means") this.means,
      @Named("settings") this.settings
  );

  final Contacts contacts;
  
  final Means means;
  
  final Settings settings;

  @override
  Future<List<Contact>> list() async => contacts.list();

  @override
  Future<Contact> item(int? id) async => contacts.item(id);

  @override
  Future<Contact> add(Contact? contact) async {
    final Contact contactCloned = Contact.copy(contact);
    return (contactCloned.id == 0) ? await contacts.post(contactCloned) : await contacts.put(contactCloned);
  }

  @override
  Future<bool> remove(Contact contact) async => contacts.delete(contact);

  @override
  Future<bool> removeContactMeans(ContactMeans? contactMeans) => means.remove(contactMeans);

  @override
  Future<ContactMeans> addContactMeans(ContactMeans? contactMeans) async {
    return contactMeans?.id == 0 ? means.post(contactMeans) : means.put(contactMeans);
  }

  @override
  Future<bool> getInstructionFisrtContactAddStatus() async {
    final Setting setting = await settings.item(Settings.instructionsFirstContactAddStatus);
    return setting.value == '1';
  }

  @override
  Future<dynamic> setInstructionFisrtContactAddStatus(bool value) async {
    final Setting setting = await settings.item(Settings.instructionsFirstContactAddStatus);
    setting.value = value ? '1' : '0';
    await settings.put(setting);
  }

  @override
  Future<bool> getInstructionFisrtContactMeansAddStatus() async {
    final Setting setting = await settings.item(Settings.instructionsFirstContactMeansAddStatus);
    return setting.value == '1';
  }

  @override
  Future<dynamic> setInstructionFisrtContactMeansAddStatus(bool value) async {
    final Setting setting = await settings.item(Settings.instructionsFirstContactMeansAddStatus);
    setting.value = value ? '1' : '0';
    await settings.put(setting);
  }
}
