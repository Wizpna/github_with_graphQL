import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GitHub_with_GraphQL extends StatefulWidget {
  @override
  _GitHub_with_GraphQLState createState() => _GitHub_with_GraphQLState();
}

class _GitHub_with_GraphQLState extends State<GitHub_with_GraphQL> {

  String readRepositories = """
  query ReadRepositories(\$nRepositories: Int!) {
    viewer {
      repositories(last: \$nRepositories) {
        nodes {
          id
          name
          viewerHasStarred
        }
      }
    }
  }
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Github with GraphQL"),
        centerTitle: true,
      ),

      body: Query(
        
        options: QueryOptions(
          document: readRepositories, // this is the query string you just created
          variables: {
            'nRepositories': 50,
          },
          pollInterval: 10,
        ),
      
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Center(child: CircularProgressIndicator());
        }

        // it can be either Map or List
        List repositories = result.data['viewer']['repositories']['nodes'];

        return ListView.builder(
          itemCount: repositories.length,
          itemBuilder: (context, index) {
            final repository = repositories[index];

            return Text(repository['name']);
        });
      },
      ),         
    );
    }
}