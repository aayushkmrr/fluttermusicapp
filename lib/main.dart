import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MUISC PLAEYr',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white10),
        )
      ),
      home: const MyHomePage(title: 'MUISC PLAEYR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color bgColor = Colors.white10;
  final OnAudioQuery _audioQuery= OnAudioQuery();

  final AudioPlayer _player= AudioPlayer();
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  void _changePlayerViewVisibility(){
    setState(() {
      isPlayerViewVisible=!isPlayerViewVisible;
    });
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration? , DurationState>(
        _player.positionStream, _player.durationStream, (position, duration)=> DurationState(
        position: position,total: duration?? Duration.zero
      ));
  @override
  void initState(){
    super.initState();
    requestStoragePermission();

    _player.currentIndexStream.listen((index) {
     if(index!=null)
       { _updateCurrentPlayingSongDetails(index);}
    });
  }
  @override
  void dispose(){
    _player.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(isPlayerViewVisible)
      {
        return Scaffold(
          backgroundColor: Colors.white10,
          body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50.0,right: 20.0,left: 20.0,bottom: 100.0),
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(

                        child: InkWell(
                         onTap: _changePlayerViewVisibility,
                         child: Container(
                           padding: EdgeInsets.all(10.0),
                           decoration: getDecoration(BoxShape.circle, const Offset(2, 2),2.0,0.0),
                           child: const Icon(Icons.arrow_back_ios_new, color: Colors.white54,),
                         ),
                        ),
                    ),
                    Flexible(
                        child: Text(
                          currentSongTitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      flex: 5,
                    ),
                  ],
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration: getDecoration(BoxShape.circle, const Offset(4, 4),55.0,20.0),
                  margin: const EdgeInsets.only(top:30, bottom: 30),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(200.0),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 4.0),
                      decoration: getRectDecoration(BorderRadius.circular(20.0),Offset(2, 2),2,0),

                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total?? Duration.zero;
                          return ProgressBar(
                              progress: progress,
                              total: total,
                              barHeight: 20.0,
                              baseBarColor: Colors.white10,
                              progressBarColor: const Color(0xEE9E9E9E),
                              thumbColor:  Colors.white24.withBlue(99),
                              timeLabelTextStyle: const TextStyle(
                                fontSize: 0,
                              ),
                              onSeek: (duration){
                                _player.seek(duration);
                              },
                          );
                        },
                      ),
                    ),
                    StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total?? Duration.zero;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                  child: Text(
                                    progress.toString().split(".")[0],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                              ),
                              Flexible(
                                child: Text(
                                  total.toString().split(".")[0],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top:10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //playpause
                      Flexible(
                          child: InkWell(
                            onTap: (){
                              if(_player.hasPrevious){
                                _player.seekToPrevious();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: getDecoration(BoxShape.circle, const Offset(2, 2),2.0,0.0),
                              child: const Icon(Icons.skip_previous , color: Colors.white70,),
                            ),
                          ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_player.playing){
                              _player.pause();
                            } else{
                              if(_player.currentIndex!=null){
                                _player.play();
                               }
                             }
                           },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                            decoration: getDecoration(BoxShape.circle, const Offset(2, 2),2.0,0.0),
                            child: StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (context,snapshot){
                                bool? playingState = snapshot.data;
                                if (playingState!= null && playingState){
                                  return const Icon(Icons.pause,size: 30, color: Colors.white70,);
                                }
                                return const Icon(Icons.play_arrow,size: 30, color: Colors.white70,);
                              },
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_player.hasNext){
                              _player.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: getDecoration(BoxShape.circle, const Offset(2, 2),2.0,0.0),
                            child: const Icon(Icons.skip_next, color: Colors.white70,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 25,
        backgroundColor: Colors.white10,
      ),
      backgroundColor: Colors.white10,
      body: Container(
        child: Scrollbar(
          thickness: 28,
          thumbVisibility: true,
        child: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item){
          if(item.data==null){return const Center(child: CircularProgressIndicator(),);}
          if(item.data!.isEmpty){return const Center(child: Text("no songs found"),);}

          songs.clear();
          songs=item.data!;
          return ListView.builder(
              itemCount:item.data!.length,
              itemBuilder: (context, index){
              return Container(
                margin: const EdgeInsets.only(top: 11.0,left: 12.0,right: 16.0),
                padding: const EdgeInsets.only(top: 5.0,bottom: 5.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: const[
                    BoxShadow(
                      blurRadius: 4.0,
                      offset: Offset(6, 6),
                      color: Colors.black45,
                    ),
                  ],
                ),
                child: ListTile(
                     textColor: Colors.white,
                     title: Text(item.data![index].title,style: const TextStyle(color: Colors.black,)),
                     subtitle: Text(item.data![index].displayName,style: const TextStyle(
                       color: Colors.white54,
                        ),
                     ),
                     trailing: const Icon(Icons.more_horiz),
                     leading: QueryArtworkWidget(
                             id: item.data![index].id,
                             type: ArtworkType.AUDIO,
                                                ),
                     onTap: () async{
                       _changePlayerViewVisibility();
                       //String? uri = item.data![index].uri;
                       //await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                       await _player.setAudioSource(
                         createPlaylist(item.data!),
                         initialIndex: index
                       );
                       await _player.play();
                     },
                ),
              );

          });
        }
      ),
      ),




      ),
      floatingActionButton: FloatingActionButton(
        child: Text('Playlist'),
        onPressed: (){},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.0),),
      ),
    );
  }
  void requestStoragePermission() async{
    if(!kIsWeb){
      bool permissionStatus= await _audioQuery.permissionsStatus();
      if(!permissionStatus){
        await _audioQuery.permissionsRequest();
      }
      setState(() { });
    }
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel>? songs)
  {
    List<AudioSource> sources = [];
    for (var song in songs!)
      {
        sources.add(AudioSource.uri(Uri.parse (song.uri!)));
      }
    return ConcatenatingAudioSource(children: sources);
  }

  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if(songs.isNotEmpty){
         currentSongTitle = songs[index].title;
         currentIndex = index;
        }
    });
  }

  getDecoration(BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      color: bgColor,
      shape: shape,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white54,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }

 BoxDecoration getRectDecoration(BorderRadius borderRadius, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      borderRadius: borderRadius,
      color: bgColor,
        boxShadow: [
          BoxShadow(
            offset: -offset,
            color: Colors.white54,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            offset: offset,
            color: Colors.black,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          )
        ],
    );
 }
}


class DurationState{
  DurationState({this.position = Duration.zero, this.total=Duration.zero});
  Duration position, total;
}


