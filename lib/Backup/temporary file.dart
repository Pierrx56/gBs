/*
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      height: screenSize.width / numberOfCard,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              temp != null
                                  ? Text(
                                      AppLocalizations.of(context)
                                          .translate('stat_nageur'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text("Check Language file (en/fr.json)"),
                              data_swim == null
                                  ? Container()
                                  : DrawCharts(data: data_swim),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('details'),
                                        )
                                      : Text(
                                          "Check Language file (en/fr.json)"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoadPage(
                                          appLanguage: appLanguage,
                                          page: "detailsCharts",
                                          user: user,
                                          messageIn: "0",
                                          scores: data_swim,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      height: screenSize.width / numberOfCard,
                      child: new GestureDetector(
                        onTap: () {
                          if (visible_swim) {
                            dispose();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadPage(
                                  appLanguage: appLanguage,
                                  page: "swimmer",
                                  user: user,
                                  messageIn: "0",
                                ),
                              ),
                            );
                          }
                        },
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          color: colorCard_swim,
                          child: SingleChildScrollView(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Stack(
                                children: <Widget>[
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 1000),
                                    opacity: !visible_swim ? 1.0 : 0.0,
                                    child: !visible_swim
                                        ? Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: temp != null
                                                    ? Text(
                                                        AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite') +
                                                            " " +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite_CMV') +
                                                            "\n\n" +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'info_nageur'),
                                                      )
                                                    : Text(
                                                        "Check Language file (en/fr.json)"),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                                                  child: temp != null
                                                      ? Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'retour'),
                                                        )
                                                      : Text(
                                                          "Check Language file (en/fr.json)"),
                                                  onPressed: () {
                                                    if (mounted)
                                                      setState(() {
                                                        visible_swim =
                                                            !visible_swim;
                                                        !visible_swim
                                                            ? colorCard_swim =
                                                                Colors.white70
                                                            : colorCard_swim =
                                                                Colors.white;
                                                      });
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                  AnimatedOpacity(
                                      duration: Duration(milliseconds: 1000),
                                      opacity: visible_swim ? 1.0 : 0.0,
                                      child: visible_swim
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/swim.png',
                                                    width: widthCard * 0.6,
                                                    height: widthCard * 0.6,
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: FlatButton.icon(
                                                    label: temp != null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'nageur'),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 24,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Check Language file (en/fr.json)"),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      color: Colors.black,
                                                    ),
                                                    splashColor: Colors.blue,
                                                    onPressed: () {
                                                      if (mounted)
                                                        setState(() {
                                                          visible_swim =
                                                              !visible_swim;
                                                          !visible_swim
                                                              ? colorCard_swim =
                                                                  Colors.white70
                                                              : colorCard_swim =
                                                                  Colors.white;
                                                        });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      height: screenSize.width / numberOfCard,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              temp != null
                                  ? Text(
                                      AppLocalizations.of(context)
                                          .translate('stat_avion'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text("Check Language file (en/fr.json)"),
                              data_plane == null
                                  ? Container()
                                  : DrawCharts(data: data_plane),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('details'),
                                        )
                                      : Text(
                                          "Check Language file (en/fr.json)"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoadPage(
                                          appLanguage: appLanguage,
                                          page: "detailsCharts",
                                          user: user,
                                          messageIn: "1",
                                          scores: data_plane,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      height: screenSize.width / numberOfCard,
                      child: new GestureDetector(
                        onTap: () {
                          if (visible_plane) {
                            dispose();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadPage(
                                  appLanguage: appLanguage,
                                  page: "plane",
                                  user: user,
                                  messageIn: "0",
                                ),
                              ),
                            );
                          }
                        },
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          color: colorCard_plane,
                          child: SingleChildScrollView(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Stack(
                                children: <Widget>[
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 1000),
                                    opacity: !visible_plane ? 1.0 : 0.0,
                                    child: !visible_plane
                                        ? Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: temp != null
                                                    ? Text(
                                                        AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite') +
                                                            " " +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite_CSI') +
                                                            "\n\n" +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'info_avion'),
                                                      )
                                                    : Text(
                                                        "Check Language file (en/fr.json)"),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                                                  child: temp != null
                                                      ? Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'retour'),
                                                        )
                                                      : Text(
                                                          "Check Language file (en/fr.json)"),
                                                  onPressed: () {
                                                    if (mounted)
                                                      setState(() {
                                                        visible_plane =
                                                            !visible_plane;
                                                        !visible_plane
                                                            ? colorCard_plane =
                                                                Colors.white70
                                                            : colorCard_plane =
                                                                Colors.white;
                                                      });
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                  AnimatedOpacity(
                                      duration: Duration(milliseconds: 1000),
                                      opacity: visible_plane ? 1.0 : 0.0,
                                      child: visible_plane
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/plane.png',
                                                    width: widthCard * 0.6,
                                                    height: widthCard * 0.6,
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: FlatButton.icon(
                                                    label: temp != null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'avion'),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 24,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Check Language file (en/fr.json)"),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      color: Colors.black,
                                                    ),
                                                    splashColor: Colors.blue,
                                                    onPressed: () {
                                                      if (mounted)
                                                        setState(() {
                                                          visible_plane =
                                                              !visible_plane;
                                                          !visible_plane
                                                              ? colorCard_plane =
                                                                  Colors.white70
                                                              : colorCard_plane =
                                                                  Colors.white;
                                                        });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),


 */