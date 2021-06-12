import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_poc/presentations/contact_page.dart';
import 'package:flutter_poc/presentations/model/bloc/contact_bloc.dart';
import 'package:flutter_poc/presentations/model/bloc/contacts_bloc.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contacts_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contacts_states.dart';
import 'package:flutter_poc/presentations/preferences_dialog.dart';

class ContactPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  ContactsBloc get contactsPageModel => context.read<ContactsBloc>();

  @override
  void initState() {
    super.initState();
    contactsPageModel.add(const ContactListViewEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
      return Scaffold(
        appBar: _buildAppBar(state),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.bottomRight,
              colorFilter: ColorFilter.mode(Colors.grey[300]?.withOpacity(0.1)??Colors.transparent, BlendMode.dstATop),
              image: const AssetImage("assets/contacts.png"),
            )
          ),
          child:
          BlocConsumer<ContactsBloc, ContactsState>(
            builder: (context, state) {
              final ContactsState content = (state is ContactsStateListener) ? state.state : state;
              if (content is ContactsEmptyListViewedState) return _buildInstructionsFirstContact(content);
              else if (content is ContactListViewedState) return _buildList(content);
              else return Container(color: Colors.transparent, child: const Center(child: Text('loading...')));
            },
            listener: (context, state) async {
              if (state is! ContactsStateListener) return;
              await _onModelStateListener(context, state);
            }
          )
        )
      );
    });
  }

  PreferredSizeWidget _buildAppBar(ContactsState state) {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: const Icon(Icons.contact_mail, size: 30),
        onPressed: () => /* TODO */ contactsPageModel.emit(ContactPreferencesViewListener(state))
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Flutter POC - Contatos'),
          const Text('Prova de conceito para uso/conhecimento do Flutter', style: TextStyle(fontSize: 10))
        ]
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.dashboard_customize, size: 30),
          onPressed: () => /* TODO */ contactsPageModel.emit(ContactListItemViewListener(state, Contact.newInstanceWithOneContactMeans()))
        )
      ],
    );
  }

  Future<void> _onModelStateListener(BuildContext context, ContactsStateListener state) async {
    FocusScope.of(context).unfocus();
    if (state is ContactPreferencesViewListener) {
      await showPreferencesDialog(context);
      contactsPageModel.add(const ContactListViewEvent());
    } else if (state is ContactListItemRemoveConfirmListener) {
      final bool isRemove = await showConfirmDialog(context, title: 'Aviso!', content: 'Voce confirma a exclusao deste contato?');
      if (isRemove) contactsPageModel.add(ContactListItemRemoveEvent(state.state, state.contact));
      else contactsPageModel.add(const ContactListViewEvent());
    } else if (state is ContactListItemRemovedListener) {
      contactsPageModel.add(const ContactListViewEvent());
      showSnackBar(context, 'Contato removido');
    } else if (state is ContactListItemViewListener) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (context) => ContactBloc(),
              child: ContactForm(Contact.copy(state.contact)),
            );
          },
        )
      );
      contactsPageModel.add(const ContactListViewEvent());
    }
  }

  Widget _buildInstructionsFirstContact(ContactsState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/contacts.add.png", height: 230),
        Container(padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15), child: Html(data: ContactBloc.instructionsFirstContactText)),
        Container(
          width: 100, 
          height: 100,
          child: IconButton(
            icon: const Icon(Icons.dashboard_customize, size: 64, color: Colors.blue),
            onPressed: () => /* TODO */ contactsPageModel.emit(ContactListItemViewListener(state, Contact.newInstanceWithOneContactMeans()))
          )
        )
      ],
    );
  }

  Widget _buildList(ContactListViewedState state) {
    return ListView.builder(
      itemCount: state.listed.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), 
              spreadRadius: 5, 
              blurRadius: 7, 
              offset: const Offset(0, 3)
            )
          ]
        ),
        child: _buildListTile(state, index)
      )
    );
  }

  Widget _buildListTile(ContactListViewedState state, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 18, right: 18),
      leading: const CircleAvatar(backgroundImage: AssetImage("assets/user.png")),
      title: Text(state.listed.elementAt(index).name ?? '', style: const TextStyle(fontSize: 14)),
      subtitle: Text(state.listed.elementAt(index).label ?? '', style: const TextStyle(fontSize: 12)),
      trailing: Container(
        width: 80,
        child: Row(
          children: [
            SizedBox(
              width: 40, 
              child: IconButton(
                icon: const Icon(Icons.edit_road, color: Colors.blue),
                onPressed: () => /* TODO */ contactsPageModel.emit(ContactListItemViewListener(state, Contact.copy(state.listed.elementAt(index))))
              )
            ),
            SizedBox(
              width: 40, 
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => /* TODO */ contactsPageModel.emit(ContactListItemRemoveConfirmListener(state, Contact.copy(state.listed.elementAt(index))))
              )
            )
          ]
        )
      )
    );
  }
}
