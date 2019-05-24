import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:test/test.dart';

void main() {

  group('Json Value', () {

    test('null', () {
      final c = FormControl<String>(initialValue: null);
      expect(c.jsonValue, null);
    });

    test('String', () {
      final c = FormControl<String>(initialValue: 'hello');
      expect(c.jsonValue, 'hello');
    });
  
    test('Integer', () {
      final c = FormControl<int>(initialValue: 4);
      expect(c.jsonValue, 4);
    });

    test('Double', () {
      final c = FormControl<double>(initialValue: 17.3);
      expect(c.jsonValue, 17.3);
    });

    test('bool', () {
      final c = FormControl<bool>(initialValue: true);
      expect(c.jsonValue, true);
    });

    test('Object', () {
      final c = FormControl<DummyData>(initialValue: DummyData(1, 'a'));
      expect(c.jsonValue, {'number': 1, 'text': 'a'});
    });

    test('Primitive List', () {
      final c = FormControl<List<String>>(initialValue: ['a', 'b']);
      expect(c.jsonValue, ['a', 'b']);
    });

    test('Primitive map', () {
      final c = FormControl<Map<String, int>>(initialValue: {'a': 1, 'b': 2});
      expect(c.jsonValue, {'a': 1, 'b': 2});
    });

    test('Object map', () {
      final c = FormControl<Map<String, DummyData>>(initialValue: {'a': DummyData(1, 'a'), 'b': DummyData(3, 'z')});
      expect(c.jsonValue, {'a': {'number': 1, 'text': 'a'}, 'b' : {'number': 3, 'text': 'z'}});
    });

    test('Object List', () {
      final c = FormControl<List<DummyData>>(initialValue: [DummyData(1, 'a'), DummyData(3, 'z')]);
      expect(c.jsonValue, [{'number': 1, 'text': 'a'}, {'number': 3, 'text': 'z'}]);
    });

    test('Nested object', () {
      final c = FormControl<NestedData>(initialValue: NestedData('howdy', DummyData(4, 'q')));
      expect(c.jsonValue, {'other': 'howdy', 'dummy': {'number': 4, 'text': 'q'}});
    });
  });
}

class DummyData {
  final int number;
  final String text;
  DummyData(this.number, this.text);
  Map<String, dynamic> toJson() {
    return {
      'number': number, 
      'text': text
    };
  }
}

class NestedData {
  final String other;
  final DummyData dummy;
  NestedData(this.other, this.dummy);
  Map<String, dynamic> toJson() {
    return {
      'other': other, 
      'dummy': dummy?.toJson()
    };
  }
}

