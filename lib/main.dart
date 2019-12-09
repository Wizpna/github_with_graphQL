import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() => runApp(

  MaterialApp(
  title: "Github with GraphQL",
  debugShowCheckedModeBanner: false,
  home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    final HttpLink httpLink = HttpLink(
    uri: 'https://api.github.com/graphql',
    headers: {
      "authorization": "Bearer 8ac9e796b0e646c5fd83ec213c07f44ece358aa5"
    }
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
    GraphQLClient(link: httpLink, cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject))
  );

  return GraphQLProvider(client: client, child: MyHomePage(),);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    String readRepositories = """
    query Flutter_Github_GraphQL{
            user(login: "wizpna") {
                avatarUrl(size: 1000)
                location
                name
                url
                email
                login
                repositories {
                  totalCount
                }
                followers {
                  totalCount
                }
                following {
                  totalCount
                }
              }
      viewer {
              starredRepositories(last: 12) {
                edges {
                  node {
                    id
                    name
                    nameWithOwner
                  }
                }
              }
            }
          }
      """;

    return Scaffold(
      appBar: AppBar(
        title: Text("Github with GraphQL"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),

      body: Query(
        
        options: QueryOptions(
          document: readRepositories,
        ),
      
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          return Center(child: Text(result.errors.toString(), style: TextStyle(fontSize: 16), 
          textAlign: TextAlign.center,));
        }

        if (result.loading) {
          return Center(child: CircularProgressIndicator());
        }

        // it can be either Map or List
        final userDetails = result.data['user'];
        List starredRepositories = result.data['viewer']['starredRepositories']['edges'];

        return Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                          child: Column(
                          children: <Widget>[
                            SizedBox(height: 2,),
                            ClipOval(
                                  child: Image.network(
                                    userDetails["avatarUrl"], filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                    height: 100.0,
                                    width: 100.0,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text(userDetails['name'], style: TextStyle(fontSize: 18, 
                            fontWeight: FontWeight.w800,
                            color: Colors.white),),
                            SizedBox(height: 5,),
                            Text(userDetails['login'], style: TextStyle(fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),),
                            SizedBox(height: 10,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            Icon(Icons.location_on, color: Colors.grey, size: 16,),
                            SizedBox(width: 5,),
                            Text(userDetails['location'], style: TextStyle(fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),)
                            ],
                            ),

                            SizedBox(height: 8,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            Icon(Icons.email, color: Colors.grey, size: 16,),
                            SizedBox(width: 5,),
                            Text(userDetails['email'], style: TextStyle(fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),)
                            ],
                            ),

                            SizedBox(height: 15,),
                            

                            Padding(
                              padding: const EdgeInsets.only(left:10.0, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(userDetails["repositories"]['totalCount'].toString(), 
                                    style: TextStyle(color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.bold),),
                                    Text("Repositories", style: TextStyle(fontSize: 15, 
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),)
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(userDetails["followers"]['totalCount'].toString(), 
                                    style: TextStyle(color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.bold),),
                                    Text("Followers", style: TextStyle(fontSize: 15, 
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),)
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(userDetails["following"]['totalCount'].toString(), 
                                    style: TextStyle(color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.bold),),
                                    Text("Following", style: TextStyle(fontSize: 15, 
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),)
                                  ],
                                )
                              
                              
                              ],),
                            ),
                          
                            SizedBox(height: 8,),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(top:10.0, bottom: 2, left: 10),
                        child: Text("Starred Repositories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      Divider(),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 310.0),
                    child: ListView.builder(
                        itemCount: starredRepositories.length,
                        itemBuilder: (context, index) {
                          final repository = starredRepositories[index];
                          return Padding(
                            padding: const EdgeInsets.only(left:10.0, top: 8, bottom: 8),
                            child: Card(
                                elevation: 0,
                                 child: Row(
                                children: <Widget>[
                                  Icon(Icons.collections_bookmark),
                                  SizedBox(width: 5,),
                                  Text(repository['node']['nameWithOwner'], 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ],
                              ),
                            ),
                          );
                      }),
                  )
                ],
        );
      },
      ),         
    );
  }
}