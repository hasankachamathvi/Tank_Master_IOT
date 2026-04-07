import 'package:flutter_test/flutter_test.dart';
import 'package:tank_master/models/tank_model.dart';

void main() {
  test('TankModel status derives from level and pump state', () {
    final low = TankModel.fromMap({'level': 20, 'pump': false});
    final full = TankModel.fromMap({'level': 90, 'pump': true});
    final filling = TankModel.fromMap({'level': 60, 'pump': true});

    expect(low.status, 'Low Level');
    expect(full.status, 'Tank Full');
    expect(filling.status, 'Filling');
  });
}

