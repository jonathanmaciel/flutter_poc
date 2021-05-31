import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_poc/presentations/preferences_dialog.dart';
import 'package:flutter_html/flutter_html.dart';

class ContactHome extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ContactHomeState();
}

class _ContactHomeState extends State<ContactHome> {

  ContactBook _contactBook = instanceLocator<ContactBook>('contactBook');

  Preference _preference = instanceLocator<Preference>('preference');

  static const String CONTACT_ICON_URL = 'https://cdn.pixabay.com/photo/2018/04/18/18/56/user-3331257_960_720.png';

  static const String INSTRUCTIONS_FIRST_CONTACT_TEXT = """
      Bem vindo!</br></br>
      Esse aplicativo tem o objetivo de organizar todos os seus contatos.</br></br>
      Para isso, o primeiro passo e <u>cadastrar o seu primeiro contato</u>, <b>e muito facil!</b></br></br>
      Clique aqui e vamos la!
  """;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _contactBook.list();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.bottomRight,
            colorFilter: ColorFilter.mode(Colors.grey[300]?.withOpacity(0.1)??Colors.transparent, BlendMode.dstATop),
            image: AssetImage("assets/contacts.png"),
          )
        ),
        child: _contactBook.isEmpty 
             ? _buildInstructionsFirstContact(context) 
             : _buildList(context)
      )
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: Icon(Icons.contact_mail, 
        size: 30.0), 
        onPressed: () => _onAppBarLeadingIconButtonPressed()
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flutter POC - Contatos'), 
          Text('Prova de conceito para uso/conhecimento do Flutter', style: TextStyle(fontSize: 10))
        ]
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.dashboard_customize, size: 30.0), 
          onPressed: () => _showContactForm()
        )
      ],
    );
  }

  Future<void> _onAppBarLeadingIconButtonPressed() async {
    final int environment = _preference.environment;
    await showPreferencesDialog(context, _preference);
    final int currentEnvironment = _preference.environment;
    if (environment != currentEnvironment) {
      await configureInstanceLocatorEnvironment(_preference.sharedPreferences);
      _contactBook = instanceLocator<ContactBook>('contactBook');
      _preference = instanceLocator<Preference>('preference');
      await _contactBook.list();
      setState(() {});
    }
  }

  Future<void> _showContactForm({Contact? contact}) async {
    await Navigator.of(context).pushNamed(PresentationRouterPaths.CONTACT_FORM, arguments: contact);
    await _contactBook.list();
    setState(() {});
  }

  Widget _buildInstructionsFirstContact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(child: Image.asset("assets/contacts.add.png", height: 230)),
        Container(padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15), child: Html(data: INSTRUCTIONS_FIRST_CONTACT_TEXT)),
        Container(
          width: 100, 
          height: 100, 
          child: IconButton(
            icon: Icon(Icons.dashboard_customize, size: 64, color: Colors.blue), 
            onPressed: () => _showContactForm()
          )
        )
      ],
    );
  }

  /* apresenta a lista de contatos */
  Widget _buildList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _contactBook.count,
      itemBuilder: (context, index) => Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(      
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(5.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), 
              spreadRadius: 5, 
              blurRadius: 7, 
              offset: Offset(0, 3)
            )
          ]
        ),
        child: _buildListTile(context, _contactBook.elementAt(index))
      )
    );
  }

  Widget _buildListTile(BuildContext context, Contact contact) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 18, right: 18),
      leading: CircleAvatar(backgroundImage: NetworkImage(CONTACT_ICON_URL)),
      title: Text(contact.name ?? '', style: TextStyle(fontSize: 14)),
      subtitle: Text(contact.label ?? '', style: TextStyle(fontSize: 12)),
      trailing: Container(
        width: 80,
        child: Row(
          children: [
            SizedBox(
              width: 40, 
              child: IconButton(
                icon: Icon(Icons.edit_road, color: Colors.blue), 
                onPressed: () =>_showContactForm(contact: contact)
              )
            ),
            SizedBox(
              width: 40, 
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red), 
                onPressed: () => _removeContact(contact)
              )
            )
          ]
        )
      )
    );
  }

  Future<void> _removeContact(Contact contact) async {
    bool? value = await showConfirmDialog(context, title: 'Aviso!', content:'Voce confirma a exclusao deste contato?');
    if (value??false) {
      await _contactBook.remove(contact);
      setState(() {});
      showSnackBar(context, 'Contato removido');
    }
  }
}
