
import 'package:get/get.dart';

class HelpAndSupportController extends GetxController implements GetxService{
  HelpAndSupportController();

  List<String> helpAndSupportTypeList = ['regular', 'legal'];
  int _helpAndSupportIndex = 0;
  int get helpAndSupportIndex => _helpAndSupportIndex;

  void setHelpAndSupportIndex(int index){
    _helpAndSupportIndex = index;
    update();
  }

}