import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_name_equal_exception.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:injectable/injectable.dart';

@Named('contactBook')
@LazySingleton(as: ContactBook)
@Environment('LOCAL')
class ContactBookLocal implements ContactBook {

  ContactBookLocal(
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
  Future<Contact> add(Contact? contact) async => (contact?.id == 0) ? await _post(contact) : await _put(contact);

  Future<Contact> _post(Contact? contact) async {
    final List<Contact> contactsListed = await contacts.listNames(contact?.name);
    if (contactsListed.isNotEmpty) throw const ContactNameEqualException();
    return contacts.post(contact);
  }

  Future<Contact> _put(Contact? contact) async {
    final List<Contact> contactsListed = await contacts.listNames(contact?.name);
    final bool isNotEmptyContactsListed = contactsListed.where((i) => i.id != contact?.id).isNotEmpty;
    if (isNotEmptyContactsListed)  throw const ContactNameEqualException();
    return contacts.put(contact);
  }

  @override
  Future<bool> remove(Contact contact) async => contacts.delete(contact);

  @override
  Future<bool> removeContactMeans(ContactMeans? contactMeans) async {
    final Contact contact = await contacts.item(contactMeans?.contact?.id);
    final bool isMeansMoreThanOne = (contact.means?.length ?? 0) > 1;
    if (isMeansMoreThanOne && (contactMeans?.isMain??false)) throw const ContactMeansMainRemovedException();
    if (contact.isSingleContactMeans()) throw const ContactMeansSingleRemovedException();
    return means.remove(contactMeans);
  }

  @override
  Future<ContactMeans> addContactMeans(ContactMeans? contactMeans) async {
    return contactMeans?.id == 0 ? _postContactMean(contactMeans) : _putContactMean(contactMeans);
  }

  Future<ContactMeans> _postContactMean(ContactMeans? contactMeans) async {
    final List<ContactMeans> meansListed = await means.listNames(contactMeans);
    if (meansListed.isNotEmpty) throw const ContactMeansNameEqualException();
    return means.post(contactMeans);
  }

  Future<ContactMeans> _putContactMean(ContactMeans? contactMeans) async {
    final List<ContactMeans> meansListed = await means.listNames(contactMeans);
    if (meansListed.isNotEmpty && meansListed.first.id != contactMeans?.id) throw const ContactMeansNameEqualException();
    return means.put(contactMeans);
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
