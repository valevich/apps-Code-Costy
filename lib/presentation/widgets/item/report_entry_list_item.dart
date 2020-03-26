import 'package:costy/data/models/report_entry.dart';
import 'package:flutter/material.dart';

class ReportEntryListItem extends StatefulWidget {
  final ReportEntry reportEntry;

  ReportEntryListItem({Key key, this.reportEntry}) : super(key: key);

  @override
  _ReportEntryListItemState createState() => _ReportEntryListItemState();
}

class _ReportEntryListItemState extends State<ReportEntryListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: FittedBox(
              child: Column(
                children: <Widget>[
                  Text(widget.reportEntry.amount.toStringAsFixed(2),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(widget.reportEntry.currency.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'From: ${widget.reportEntry.sender.name}',
            ),
            Divider(
              thickness: 0.4,
            ),
          ],
        ),
        subtitle: Text(
          'To: ${widget.reportEntry.receiver.name}',
        ),
      ),
    );
  }
}
