import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgreementScreen extends StatelessWidget {
  final String docs;
  const AgreementScreen({Key key, this.docs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            docs,
            style: GoogleFonts.dmSans(),
          ),
        ),
      ),
    );
  }
}

AppBar buildAppBar() {
  return AppBar(
    title: Text(
      "User agreement",
      style: GoogleFonts.dmSans(),
    ),
    elevation: 0,
    centerTitle: true,
  );
}
