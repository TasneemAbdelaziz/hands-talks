import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class CustomSearchBar extends StatefulWidget {
  List<Contact> contacts;

  CustomSearchBar({super.key,required this.contacts});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();

}

class _CustomSearchBarState extends State<CustomSearchBar> {


  SearchController searchController = SearchController();

List<Contact> historySearch =[];

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text;
    return widget.contacts
        .where((contact)=>
        (contact.displayName.toLowerCase().contains(input) ||
        contact.phones.any((phone) => phone.number.contains(input)))).take(10)
        .map(
          (contact) => ListTile(
        // leading: CircleAvatar(backgroundColor: filteredColor.color),
        title: Text(contact.displayName),
        trailing: IconButton(
          icon: const Icon(Icons.call_missed),
          onPressed: () {
          },
        ),
        onTap: () {
          controller.closeView(contact.displayName);
          handleSelection(contact);

        },
      ),
    );
  }

  void handleSelection(Contact selectedContact) {
    setState(() {
      if (historySearch.length >= 5) {
        historySearch.removeLast();
      }
      historySearch.insert(0, selectedContact);
    });
  }



  Iterable<Widget> getHistoryList(SearchController controller) {
    return historySearch.map(
          (Contact contact) =>
              ListTile(
        leading: const Icon(Icons.history),
        title: Text(contact.displayName),
        trailing: IconButton(
          icon: InkWell(
              onTap: (){
                setState(() {
                  historySearch.remove(contact);
                });
              },
              child: const Icon(Icons.close)),
          onPressed: () {

          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(10),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              controller.openView();
            },
          );
        },
        isFullScreen: false,
        suggestionsBuilder: (context,SearchController searchController){

          if(searchController.text.isEmpty){
            if(historySearch.isNotEmpty){
              return getHistoryList(searchController);
            }
            return <Widget>[
              const Center(child: Text("No Search History"))
            ];
          }
          return getSuggestions(searchController);
        },

      ),
    );
  }
}
