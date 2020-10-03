import 'package:adword/models/CustomUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final CustomUser user;
  ProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(0, 204, 184, 1),
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    20,
                  ),
                  topRight: Radius.circular(
                    20,
                  ),
                ),
              ),
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      height: 80,
                    ),
                    Column(
                      children: [
                        Text(
                          "From",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Nexus Endeavors",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              });
        },
        child: Icon(
          Icons.arrow_drop_up,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.dmSans(),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              ClipOval(
                child: CachedNetworkImage(
                  width: 120,
                  imageUrl: widget.user.imageurl,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Box(data: widget.user.code, title: "Profile ID"),
              Box(data: widget.user.username, title: "Name"),
              Box(data: widget.user.religion, title: "Religion"),
              Box(data: widget.user.caste, title: "Caste"),
              Box(data: widget.user.gender, title: "Gender"),
              Box(data: widget.user.age.toString(), title: "Age"),
              Box(data: widget.user.maritalStatus, title: "Marital Status"),
              Box(data: widget.user.phonenumber, title: "Contact Number"),
              Box(data: widget.user.weblink, title: "Profile Link"),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Box extends StatelessWidget {
  const Box({
    Key key,
    @required this.data,
    this.title,
  }) : super(key: key);

  final String data;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              data,
              style: GoogleFonts.dmSans(),
            ),
          )
        ],
      ),
    );
  }
}
