import 'package:percepts/percepts.dart';
import 'package:flutter/material.dart';

import '../../icons/icons.dart' as icons;
import '../../beliefs/introspection_beliefs.dart';
import '../../beliefs/viewmodels/beliefs_view_view_model.dart';
import 'beliefs_tree/key_provider.dart';
import 'beliefs_tree/primitives/tree_controller.dart';
import 'beliefs_tree/primitives/tree_node.dart';
import 'beliefs_tree/widgets/tree_view.dart';

class BeliefsView extends StatelessWidget {
  final _keyProvider = KeyProvider();
  final _controller = TreeController(allNodesExpanded: false);

  BeliefsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamOfConsciousness<IntrospectionBeliefs, BeliefsViewViewModel>(
        infer: (state) =>
            BeliefsViewViewModel(state.selectedState, state.previousState),
        builder: (context, vm) {
          return Center(
            child: TreeView(
              toTreeNodes(vm.selectedAppState, vm.previousAppState),
              treeController: _controller,
            ),
          );
        });
  }

  List<TreeNode> toTreeNodes(dynamic currentJson, dynamic previousJson) {
    if (currentJson is Map<String, dynamic>) {
      return currentJson.keys
          .map(
            (k) => TreeNode(
              toTreeNodes(
                currentJson[k],
                (previousJson == null) ? null : previousJson[k],
              ),
              key: _keyProvider.nextKey(),
              content: Text('$k:'),
            ),
          ) //
          .toList();
    }
    if (currentJson is List<dynamic>) {
      return currentJson
          .asMap()
          .map(
            (i, element) => MapEntry(
              i,
              TreeNode(
                toTreeNodes(
                  element,
                  previousJson == null ||
                          (previousJson as List).isEmpty ||
                          i >= previousJson.length
                      ? null
                      : previousJson.elementAt(i),
                ),
                key: _keyProvider.nextKey(),
                content: Text('[$i]:'),
              ),
            ),
          ) //
          .values
          .toList();
    }

    // Not a map or list so leaf - save a key in case we want to use it
    final key = _keyProvider.nextKey();
    final changed = currentJson != previousJson;
    if (changed) _controller.expandNode(key);
    return [
      TreeNode(
        [],
        key: key,
        content: !changed // no change -> print in black
            ? Text(currentJson.toString())
            : previousJson == null // new value was added -> show in green
                ? Text(currentJson.toString())
                : Row(
                    children: [
                      Text(previousJson.toString(), style: oldStyle),
                      icons.rightArrow,
                      Text(currentJson.toString(), style: newStyle)
                    ],
                  ),
      ) // otherwise show difference
    ];
  }
}

final oldStyle = TextStyle(
  fontSize: 20,
  backgroundColor: Colors.red[200],
  foreground: Paint()..color = Colors.red[700]!,
  decoration: TextDecoration.lineThrough,
  decorationColor: Colors.red[700],
);

final newStyle = TextStyle(
  fontSize: 20,
  backgroundColor: Colors.green[200],
  foreground: Paint()..color = Colors.green[700]!,
);