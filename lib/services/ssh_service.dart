import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class SSHService {
  SSHClient? _client;
  bool _isConnected = false;
  String? lastError;

  bool get isConnected => _isConnected;

  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    try {
      final socket = await SSHSocket.connect(host, port,
          timeout: const Duration(seconds: 10));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      await _client!.authenticated;
      _isConnected = true;

      // Upload assets to LG on connect
      await execute('mkdir -p /var/www/html/kml');
      await _uploadAsset('assets/images/lg_logo.png', '/var/www/html/kml/lg_logo.png');
      await _uploadAsset('assets/images/taj_mahal.png', '/var/www/html/kml/taj_mahal.png');
      await _uploadAsset('assets/images/petra.png', '/var/www/html/kml/petra.png');
      await _uploadAsset('assets/images/machu_picchu.png', '/var/www/html/kml/machu_picchu.png');
      await _uploadAsset('assets/images/pyramids.png', '/var/www/html/kml/pyramids.png');
      return true;
    } catch (e) {
      _isConnected = false;
      _client = null;
      lastError = e.toString();
      debugPrint('SSH Connection Error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await clearKML();
      _client?.close();
    } catch (e) {
      debugPrint('SSH Disconnect Error: $e');
    } finally {
      _client = null;
      _isConnected = false;
    }
  }

  Future<String?> execute(String command) async {
    if (_client == null || !_isConnected) return null;
    try {
      final result = await _client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      debugPrint('SSH Execute Error: $e');
      return null;
    }
  }

  /// Upload a Flutter asset to LG via SFTP
  Future<void> _uploadAsset(String assetPath, String remotePath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final sftp = await _client!.sftp();
      final file = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );
      await file.write(Stream.value(bytes));
      await file.close();
      debugPrint('Uploaded $assetPath');
    } catch (e) {
      debugPrint('Upload error ($assetPath): $e');
    }
  }

  /// Write KML to slave via SFTP
  Future<void> _writeKMLFile(String path, String kml) async {
    if (_client == null || !_isConnected) return;
    try {
      final sftp = await _client!.sftp();
      final bytes = Uint8List.fromList(utf8.encode(kml));
      final file = await sftp.open(
        path,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );
      await file.write(Stream.value(bytes));
      await file.close();
    } catch (e) {
      debugPrint('KML write error: $e');
    }
  }

  Future<void> sendKMLToSlave(int slaveNumber, String kml) async {
    await _writeKMLFile('/var/www/html/kml/slave_$slaveNumber.kml', kml);
  }

  /// Fly to a location
  Future<void> flyTo(
      double lat, double lng, double alt, double heading, double tilt, double range) async {
    final cmd =
        "echo 'flytoview=<LookAt><longitude>$lng</longitude><latitude>$lat</latitude>"
        "<altitude>$alt</altitude><heading>$heading</heading><tilt>$tilt</tilt>"
        "<range>$range</range><altitudeMode>relativeToGround</altitudeMode>"
        "</LookAt>' > /tmp/query.txt";
    await execute(cmd);
  }

  /// Clear all KML overlays
  Future<void> clearKML() async {
    const emptyKml =
        '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><name>None</name></Document></kml>';
    for (int i = 2; i <= 3; i++) {
      await sendKMLToSlave(i, emptyKml);
    }
  }

  /// Set LG logo on left slave (screen 3)
  Future<void> setLogoOverlay() async {
    const logoKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<NetworkLinkControl>
  <minRefreshPeriod>86400</minRefreshPeriod>
</NetworkLinkControl>
<Document>
  <name>LG Logo</name>
  <ScreenOverlay>
    <name>Logo</name>
    <Icon><href>lg_logo.png</href></Icon>
    <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
    <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
    <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <size x="0" y="0.2" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</Document>
</kml>''';
    await sendKMLToSlave(3, logoKml);
  }

  /// Set info panel on right slave (screen 2) with black background
  Future<void> setInfoPanelOverlay({
    required String title,
    required String country,
    required String year,
    required String category,
    required String description,
    required String imageFile,
  }) async {
    // Using <text> in BalloonStyle removes the default "Directions" footer
    final infoPanelKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
<NetworkLinkControl>
  <minRefreshPeriod>86400</minRefreshPeriod>
</NetworkLinkControl>
<Document>
  <name>Info Panel</name>
  <Style id="infoStyle">
    <BalloonStyle>
      <bgColor>ff000000</bgColor>
      <textColor>ffffffff</textColor>
      <text><![CDATA[
<table width="400" cellpadding="8" cellspacing="0" bgcolor="black">
<tr><td>
<img src="$imageFile" width="380" height="220"/>
</td></tr>
<tr><td>
<font size="5" color="#4CAF50"><b>Title: $title</b></font><br/>
<font size="3" color="white">Country: $country</font><br/>
<font size="3" color="white">Year of Inscription: $year</font><br/>
<font size="3" color="white">Category: $category</font><br/>
<br/>
<font size="4" color="#4CAF50"><b>Description:</b></font><br/>
<font size="3" color="white">$description</font>
</td></tr>
</table>
]]></text>
    </BalloonStyle>
  </Style>
  <Placemark>
    <name></name>
    <styleUrl>#infoStyle</styleUrl>
    <gx:balloonVisibility>1</gx:balloonVisibility>
    <Point>
      <coordinates>0,0,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>''';
    await sendKMLToSlave(2, infoPanelKml);
  }

  /// Fly to monument with overlays
  Future<void> flyToMonument({
    required String name,
    required double latitude,
    required double longitude,
    required double altitude,
    required double heading,
    required double tilt,
    required double range,
    required String country,
    required String year,
    required String category,
    required String description,
  }) async {
    // Set logo on left slave
    await setLogoOverlay();

    // Fly to the monument
    await flyTo(latitude, longitude, altitude, heading, tilt, range);

    // Map monument names to uploaded image filenames (local on LG)
    final imageFiles = {
      'Taj Mahal': 'taj_mahal.png',
      'Petra': 'petra.png',
      'Machu Picchu': 'machu_picchu.png',
      'Pyramids of Giza': 'pyramids.png',
    };

    // Set info panel on right slave
    await setInfoPanelOverlay(
      title: name,
      country: country,
      year: year,
      category: category,
      description: description.replaceAll('\n', '<br/>'),
      imageFile: imageFiles[name] ?? '',
    );
  }
}
