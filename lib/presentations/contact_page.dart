import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_name_equal_exception.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_poc/presentations/instructions_dialog.dart';
import 'package:flutter_poc/presentations/contact_means_dialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_poc/main.dart';

class ContactForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {

  Contact contact = Contact.newInstanceWithOneContactMeans();

  final ContactBook contactBook = instanceLocator<ContactBook>('contactBook');

  final GlobalKey<FormState> formId = new GlobalKey<FormState>();

  bool _isContactNameInvalid = false;
  bool _isContactMeansNameInvalid = false;
  bool _isContactMeansValueInvalid = false;

  static const String CONTACT_ICON_URL = 'https://cdn.pixabay.com/photo/2018/04/18/18/56/user-3331257_960_720.png';

  static const String INSTRUCTIONS_FIRST_CONTACT_MEANS_TEXT = """
      <b>Pronto!</b><br/><br/>Agora podemos adicionar meios para contato ao seu novo contato, 
      basta acionar o botao na barra inferior do App e testar.<br/><br/>
      Mais uma coisa, ha uma opcao para determinar o contato principal que sera apresentado junto com as 
      informacoes do seu contato na tela principal.
  """;

  static const String INSTRUCTIONS_FIRST_CONTACT_TEXT = """
      Por hora, priorizaremos os dados mais importantes para contactar alguem:<br/><br/>
      O <b><i>nome</i></b> que voce ira identificar o contato<br/><br/>
      Uma breve <b><i>descricao</i></b> que representa a sua relacao com o contato<br/><br/>
      e o <b><i>meio</i></b> para contacta-lo. <br/><br/>Apos isso te mostraremos mais opcoes.
  """;

  static const double HEIGHT_SIZE_CONTACT_ADD = 320;

  static const double HEIGHT_SIZE_CONTACT_UPDATE = 200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      bool instructionFisrtContactAddStatus = await contactBook.getInstructionFisrtContactAddStatus();
      if (contact.id == 0 && instructionFisrtContactAddStatus) {
        bool? value = await showInstructionsDialog(context, instructionFisrtContactAddStatus, 
            'Primeiro contato...', INSTRUCTIONS_FIRST_CONTACT_TEXT);
        contactBook.setInstructionFisrtContactAddStatus(value ?? false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigatorRouteArguments = ModalRoute.of(context)?.settings.arguments;    
    if (navigatorRouteArguments != null) contact = navigatorRouteArguments as Contact;
    return Scaffold(
      appBar: _buildAppbar(context),
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.bottomCenter,
            colorFilter: contact.id == 0 
                ? null
                : ColorFilter.mode(Colors.grey[300]?.withOpacity(0.5)??Colors.transparent, BlendMode.dstATop),
            image: AssetImage("assets/contact.means.add2.png"),
          )
      ),
        child: contact.id == 0
             ? _buildInstructionsFirstContactMeans(context)
             : _buildList(context, contact)
      ),
      floatingActionButton: contact.id == 0 ? null : _buildFloatingActionButton(context),
      floatingActionButtonLocation: contact.id == 0 ? null : FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar: contact?.id == 0 ? null : _buildBottomBar(context)
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      toolbarHeight: contact.id == 0 ? HEIGHT_SIZE_CONTACT_ADD : HEIGHT_SIZE_CONTACT_UPDATE,
      shape: _ContactFormShapeBorder(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact.id == 0 ? 'Novo Contato' : 'Contato'),
          Text(contact.id == 0 ? 'Aqui voce pode cadastrar um novo contato' : 'Aqui voce pode visualizar/atualizar os dados do cantato', 
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.zero, 
        child: _buildForm(context)
      ),
      actions: <Widget>[
        Visibility(
          child: IconButton(
            icon: Icon(contact.id == 0 ? Icons.dashboard_customize : Icons.edit_road, size: 30.0),
            onPressed: () => _insertOrUpdateContact(),
          )
        )
      ]
    );
  }

  Widget _buildInstructionsFirstContactMeans(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, 
        mainAxisAlignment: MainAxisAlignment.end, 
        children: [
          Container(
            width: 100,
            height: 100,
            padding: EdgeInsets.only(left: 15, right: 15, top: 30), 
            child: IconButton(
              icon: Icon(Icons.dashboard_customize, color: Colors.blue, size: 64),
              onPressed: () => _insertOrUpdateContact(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 130),
            child: Html(data: '<p style="text-align:center;">Informe os dados para contato e <u>clique aqui</u>!</p>')
          )
        ]
      )
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: contact.id == 0 ? 30 : 0),
      child: Form(
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formId,
        child: Column(
          children: [
            Container(child: CircleAvatar(backgroundImage: NetworkImage(CONTACT_ICON_URL))),
            SizedBox(
              width: 200,
              height: 40,
              child: TextFormField(
                initialValue: contact.name,
                decoration: InputDecoration(
                  hintText: _isContactNameInvalid ? 'digite nome...' :'nome...', 
                  // contentPadding: EdgeInsets.fromLTRB(0.0, 7, 7, 0.0),
                  hintStyle: TextStyle(
                    fontStyle: FontStyle.italic, 
                    color: _isContactNameInvalid ? Colors.red : Colors.white
                  ),
                  errorStyle: TextStyle(fontSize: 0, height: 0),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[400]??Colors.blue)),  
                  errorBorder: _isContactNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                  focusedErrorBorder: _isContactNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                ),
                style: TextStyle(fontSize: 14, color: Colors.white),
                validator: (newValue) {
                  _isContactNameInvalid = (newValue?.trim().isEmpty??false);
                   return _isContactNameInvalid ? '' : null;
                },
                onSaved: (newValue) => contact.name = newValue ?? '',
                onTap: () {
                  if (_isContactNameInvalid) {
                    setState(() {
                      _isContactNameInvalid = false;
                    });
                  }    
                },
                onChanged: (value) {
                  if (_isContactNameInvalid) {
                    setState(() {
                      _isContactNameInvalid = false;
                    });
                  }    
                },
              )
            ),
            SizedBox(
              width: 200,
              height: 40,
              child: TextFormField(
                initialValue: contact.description,
                decoration: InputDecoration(
                  hintText: 'descricao...', 
                  // contentPadding: EdgeInsets.fromLTRB(0.0, 7, 7, 0.0),
                  
                  hintStyle: TextStyle(
                    fontStyle: FontStyle.italic, 
                    color: Colors.white
                  ),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),  
                ),
                style: TextStyle(fontSize: 14, color: Colors.white),
                onSaved: (newValue) => contact.description = newValue ?? ''
              )
            ),
            Visibility(
              visible: contact.id == 0,
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextFormField(
                  initialValue: '',
                  decoration: InputDecoration(
                    hintText: _isContactMeansNameInvalid ? 'digite meio para contato...' :'meio para contato...', 
                    hintStyle: TextStyle(
                      fontStyle: FontStyle.italic, 
                      color: _isContactMeansNameInvalid ? Colors.red : Colors.white
                    ),
                    // contentPadding: EdgeInsets.fromLTRB(0.0, 7, 7, 0.0),
                    errorStyle: TextStyle(fontSize: 0, height: 0),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[400]??Colors.blue)),  
                    errorBorder: _isContactMeansNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                    focusedErrorBorder: _isContactMeansNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  validator: (newValue) => (_isContactMeansNameInvalid = (newValue?.trim().isEmpty??false)) ? '' : null,
                  onSaved: (newValue) => contact.means?.first.name = newValue ?? '',
                  onTap: () {
                    if (_isContactMeansNameInvalid) {
                      setState(() {
                        _isContactMeansNameInvalid = false;
                      });
                    }    
                  },
                  onChanged: (value) {
                    if (_isContactMeansNameInvalid) {
                      setState(() {
                        _isContactMeansNameInvalid = false;
                      });
                    }    
                  },
                )
              )
            ),
            Visibility(
              visible: contact.id == 0,
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextFormField(
                  initialValue: '',
                  decoration: InputDecoration(
                    hintText: _isContactMeansValueInvalid ? 'digite o contato...' :'contato...', 
                    // contentPadding: EdgeInsets.fromLTRB(0.0, 7, 7, 0.0),
                    hintStyle: TextStyle(
                      fontStyle: FontStyle.italic, 
                      color: _isContactMeansValueInvalid ? Colors.red : Colors.white
                    ),
                    errorStyle: TextStyle(fontSize: 0, height: 0),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[400]??Colors.blue)),  
                    errorBorder: _isContactMeansValueInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                    focusedErrorBorder: _isContactMeansValueInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)), 
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  validator: (newValue) => (_isContactMeansValueInvalid = (newValue?.trim().isEmpty??false)) ? '' : null,
                  onSaved: (newValue) => contact.means?.first.value = newValue ?? '',
                  onTap: () {
                    if (_isContactMeansValueInvalid) {
                      setState(() {
                        _isContactMeansValueInvalid = false;
                      });
                    }
                  },
                  onChanged: (value) {
                    if (_isContactMeansValueInvalid) {
                      setState(() {
                        _isContactMeansValueInvalid = false;
                      });
                    }
                  },
                )
              )
            ),
            // SizedBox(height: 12)
          ],
        ),
      )
    );
  }

  Future<void> _insertOrUpdateContact() async {
    FocusScope.of(context).unfocus();
    bool isValid = formId.currentState?.validate() ?? false;
    if (isValid) {
      formId.currentState?.save();
      final bool isNewContact = contact.id == 0;
      try {
          contact = await contactBook.add(contact);
      } on ContactNameEqualException catch (e) {
        showSnackBar(context, e.message ?? '', error: true);
        return;
      } catch (e) {
        showSnackBar(context, e.toString(), error: true);
        return;
      }
      showSnackBar(context, 'Contato atualizado');
      bool instructionFisrtContactMeansAddStatus = await contactBook.getInstructionFisrtContactMeansAddStatus();
      if (isNewContact && instructionFisrtContactMeansAddStatus) {
        bool? value = await showInstructionsDialog(context, instructionFisrtContactMeansAddStatus, 
            'Meios para contato...', INSTRUCTIONS_FIRST_CONTACT_MEANS_TEXT);
        contactBook.setInstructionFisrtContactMeansAddStatus(value ?? false);
      }
      setState(() { });
    }
  }

  Widget _buildList(BuildContext context, Contact? contact) {
    return Container(
      padding: EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 16),
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: contact?.means?.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(5.0),
              topRight: const Radius.circular(5.0),
              bottomLeft: const Radius.circular(5.0),
              bottomRight: const Radius.circular(5.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: (5 / 2),
                blurRadius: (7 / 1),
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: _buildListTile(context, contact?.means?.elementAt(index)),
        ),
      )
    );
  }

  Widget _buildListTile(BuildContext context, ContactMeans? mean) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 18, right: 18),
      leading: CircleAvatar(backgroundImage: NetworkImage(CONTACT_ICON_URL)),
      title: Text(mean?.name ?? '', style: TextStyle(fontSize: 14)),
      subtitle: Text(mean?.value ?? '', style: TextStyle(fontSize: 12)),
      trailing: Container(
        width: 120,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(Icons.edit_road, color: Colors.blue), 
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  mean?.contact = contact;
                  await showContactMeansFormDialog(context, mean);
                  setState(() { });
                }
              )
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _onListTileIconButtonRemovePressed(mean)
              )
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: mean?.isMain??false || (contact.isSingleContactMeans())
                    ? Icon(Icons.check_box, color: Colors.blue)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: contact.means?.length == 1 ? null : () => _onListTileCheckBoxPressed(mean)
              )
            )
          ],
        )
      ),
    );
  }

  Future<void> _onListTileIconButtonRemovePressed(ContactMeans? contactMeans) async {
    FocusScope.of(context).unfocus();
    final bool? isItemRemoved = await showConfirmDialog(context, 
        title: 'Aviso!', content: 'Voce confirma a exclusao deste contato?');
    if (isItemRemoved??false) {
      contactMeans?.contact = contact;
      try {
        await contactBook.removeContactMean(contactMeans);
        setState(() {});
        showSnackBar(context, 'Meio para contato removido');
      } on ContactMeansMainRemovedException catch (e) {
        showSnackBar(context, e.message ?? '', error: true);
      } on ContactMeansSingleRemovedException catch (e) {
        final bool? isRemove = await showConfirmDialog(context, title: 'Aviso!', content: e.message);
        FocusScope.of(context).unfocus();
        if (isRemove ?? false) {
          await contactBook.remove(Contact(contact.id, '', ''));
          Navigator.of(context).pop(true);
          showSnackBar(context, 'Contato removido');
        }
      }
    }
  }

  Future<void> _onListTileCheckBoxPressed(ContactMeans? contactMeans) async {
    contactMeans?.isMain = !(contactMeans.isMain ?? false);
    contactMeans?.contact = contact;
    await contactBook.addContactMean(contactMeans);
    setState(() {});
    FocusScope.of(context).unfocus();
    showSnackBar(context, 
        'Meio para contato principal atualizado para \n${contactMeans?.name}: ${contactMeans?.value}');
  }

  _buildFloatingActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 27, bottom: 13),
      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final bool isValid = formId.currentState?.validate() ?? false;
          if (isValid) {
            await showContactMeansFormDialog(context, ContactMeans.newInstance(contact));
            setState(() {});
          }
        }
      )
    );
  }  
}

class _ContactFormShapeBorder extends ContinuousRectangleBorder {

  static const double INNER_CIRCLE_RADIUS = 150.0;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double q1Width = rect.width / 12;
    final double cWidth = rect.width / 2;
    final double q2Width = rect.width / 2;
    final height = rect.height == _ContactFormState.HEIGHT_SIZE_CONTACT_ADD 
                 ? rect.height 
                 : rect.height - (rect.height / 4);
    Path path = Path();
    path.lineTo(0, height);
    path.quadraticBezierTo(q1Width - (INNER_CIRCLE_RADIUS / 10) - 30, height + 15, q1Width - 75, height + 70);
    path.cubicTo(cWidth, height + INNER_CIRCLE_RADIUS - 40, cWidth + 40, 
        height + INNER_CIRCLE_RADIUS - 40, cWidth + 80, height + 80);
    path.quadraticBezierTo(q2Width + (INNER_CIRCLE_RADIUS / 2) + 60, height + 40, rect.width + 160, height + 120);
    path.lineTo(rect.width, 0);
    path.close();
    return path;
  }
}
