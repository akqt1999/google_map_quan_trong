import 'package:flutter/material.dart';
import 'package:testspappp/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion>{

  final sessionToken;
  PlaceApiProvider apiClient;

  AddressSearch(this.sessionToken){
    apiClient=PlaceApiProvider(sessionToken);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
      return [
        IconButton(onPressed: (){
          query="";
        }, icon: Icon(Icons.clear))
      ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      close(context, null);
    }, icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
      return FutureBuilder(
        future: query==""?null:apiClient.fetchSuggestions(query),
          builder: (context,snapshot)=>query==""?
          Container(child: const Text("enter you address"),):
              snapshot.hasData?ListView.builder(itemCount: snapshot.data.length, itemBuilder: (context,index)=>
                  ListTile(title: Text((snapshot.data[index] as Suggestion).description),
                    onTap: (){
                    close(context, snapshot.data[index]);
                    },

                  ))
                  :Container(child:  const Center(child: CircularProgressIndicator()),)

      );
  }

}