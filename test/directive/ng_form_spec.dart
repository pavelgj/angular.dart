library form_spec;

import '../_specs.dart';

void main() {
  describe('form', () {
   TestBed _;

    it('should set the name of the form and attach it to the scope', (Scope scope, TestBed _) {
      var element = $('<form name="myForm"></form>');

      expect(scope.context['myForm']).toBeNull();

      _.compile(element);
      scope.apply();

      expect(scope.context['myForm']).toBeDefined();

      var form = scope.context['myForm'];
      expect(form.name).toEqual('myForm');
    });

    it('should return the first control with the given name when accessed using map notation',
      (Scope scope, TestBed _) {

      var element = $('<form name="myForm">' +
                      '  <input type="text" name="model" ng-model="modelOne" probe="a" />' +
                      '  <input type="text" name="model" ng-model="modelTwo" probe="b" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      NgForm form = _.rootScope.context['myForm'];
      NgModel one = _.rootScope.context['a'].directive(NgModel);
      NgModel two = _.rootScope.context['b'].directive(NgModel);

      expect(one).not.toBe(two);
      expect(form['model']).toBe(one);
      expect(scope.eval("myForm['model']")).toBe(one);
    });

    it('should return the all the controls with the given name', (Scope scope, TestBed _) {
      var element = $('<form name="myForm">' +
                      '  <input type="text" name="model" ng-model="modelOne" probe="a" />' +
                      '  <input type="text" name="model" ng-model="modelTwo" probe="b" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      NgForm form = _.rootScope.context['myForm'];
      NgModel one = _.rootScope.context['a'].directive(NgModel);
      NgModel two = _.rootScope.context['b'].directive(NgModel);

      expect(one).not.toBe(two);

      var controls = form.controls['model'];
      expect(controls[0]).toBe(one);
      expect(controls[1]).toBe(two);

      expect(scope.eval("myForm.controls['model'][0]")).toBe(one);
      expect(scope.eval("myForm.controls['model'][1]")).toBe(two);
    });


    describe('pristine / dirty', () {
      it('should be set to pristine by default', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"></form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        expect(form.pristine).toEqual(true);
        expect(form.dirty).toEqual(false);
      });

      it('should add and remove the correct CSS classes when set to dirty and to pristine', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"><input ng-model="m" probe="m" /></form>');

        _.compile(element);
        scope.apply();

        Probe probe = _.rootScope.context['m'];
        var input = probe.directive(NgModel);
        var form = scope.context['myForm'];

        input.addInfo('ng-dirty');
        input.validate();
        scope.apply();

        expect(form.pristine).toEqual(false);
        expect(form.dirty).toEqual(true);
        expect(element.hasClass('ng-pristine')).toBe(false);
        expect(element.hasClass('ng-dirty')).toBe(true);

        input.removeInfo('ng-dirty');
        input.validate();
        scope.apply();

        expect(form.pristine).toEqual(true);
        expect(form.dirty).toEqual(false);
        expect(element.hasClass('ng-pristine')).toBe(true);
        expect(element.hasClass('ng-dirty')).toBe(false);
      });

      it('should revert back to pristine on the form if the value is reset on the model',
        (Scope scope, TestBed _) {

        var element = $('<form name="myForm">' + 
                        '  <input type="text" ng-model="myModel1" probe="m" />' +
                        '  <input type="text" ng-model="myModel2" probe="n" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        var model1 = scope.context['m'].directive(NgModel);
        var model2 = scope.context['n'].directive(NgModel);

        expect(model1.pristine).toBe(true);
        expect(model2.pristine).toBe(true);
        expect(form.dirty).toBe(false);

        var m1value = model1.viewValue;
        var m2value = model2.viewValue;

        model1.viewValue = 'some value';
        expect(model1.dirty).toBe(true);
        expect(model1.pristine).toBe(false);
        expect(form.dirty).toBe(true);

        model2.viewValue = 'some value 123';

        model1.viewValue = m1value;
        expect(model1.dirty).toBe(false);
        expect(model1.pristine).toBe(true);
        expect(form.pristine).toBe(false);

        model2.viewValue = m2value;
        expect(model2.dirty).toBe(false);
        expect(model2.pristine).toBe(true);
        expect(form.pristine).toBe(true);
      });
    });

    describe('valid / invalid', () {
      it('should be valid when empty', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"></form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        expect(form.valid).toBe(true);
      });

      it('should be valid by default', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"><input type="text" /></form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        expect(form.valid).toBe(true);
      });

      it('should add and remove the correct flags when set to valid and to invalid',
        (Scope scope, TestBed _) {

        var element = $('<form name="myForm"><input ng-model="m" probe="m" /></form>');
        _.compile(element);
        scope.apply();

        Probe probe = _.rootScope.context['m'];
        var model = probe.directive(NgModel);
        var form = scope.context['myForm'];

        model.addError('some-error');
        model.validate();
        scope.apply();

        expect(form.valid).toEqual(false);
        expect(form.invalid).toEqual(true);

        //expect(element.hasClass('ng-valid')).toBe(false);
        expect(element.hasClass('ng-invalid')).toBe(true);

        model.removeError('some-error');
        model.validate();
        scope.apply();

        expect(form.valid).toEqual(true);
        expect(form.invalid).toEqual(false);
        expect(element.hasClass('ng-invalid')).toBe(false);
        // expect(element.hasClass('ng-valid')).toBe(true);
      });

      it('should set the validity with respect to all existing validations when error states are set is used', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="one" name="one" />' +
                        '  <input type="text" ng-model="two" name="two" />' +
                        '  <input type="text" ng-model="three" name="three" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];
        NgModel three = form['three'];

        one.addError("some error");
        one.validate();
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        two.addError("some error");
        two.validate();
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        one.removeError("some error");
        one.validate();
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        two.removeError("some error");
        two.validate();
        expect(form.valid).toBe(true);
        expect(form.invalid).toBe(false);
      });

      it('should collect the invalid models upon failed validation', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="one" name="one" />' +
                        '  <input type="text" ng-model="two" name="two" />' +
                        '  <input type="text" ng-model="three" name="three" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];
        NgModel three = form['three'];

        one.addError("email");
        two.removeError("number");
        three.addError("format");

        expect(form.errorStates.keys.length).toBe(2);
        expect(form.errorStates['email'].elementAt(0)).toBe(one);
        expect(form.errorStates['format'].elementAt(0)).toBe(three);
      });


      it('should not handle the control errorType pair more than once', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="one" name="one" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];

        one.addError('validation error');
        one.validate();
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        one.addError('validation error');
        one.validate();
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        one.removeError('validation error');
        one.validate();
        expect(form.valid).toBe(true);
        expect(form.invalid).toBe(false);
      });

      it('should update the validity of the parent form when the inner model changes', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="one" name="one" />' +
                        '  <input type="text" ng-model="two" name="two" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];

        one.addError("required");
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        two.addError("required");
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        one.removeError("required");
        expect(form.valid).toBe(false);
        expect(form.invalid).toBe(true);

        two.removeError("required");
        expect(form.valid).toBe(true);
        expect(form.invalid).toBe(false);
      });

      it('should register the name of inner forms that contain the ng-form attribute',
        (Scope scope, TestBed _) {

        var element = $('<form name="myForm">'
                        '  <div ng-form="myInnerForm" probe="f">' +
                        '    <input type="text" ng-model="one" name="one" probe="m" />' +
                        '  </div>' +
                        '</form>');

        _.compile(element);
        scope.apply(() {
          scope.context['one'] = 'it works!';
        });

        var form = scope.context['myForm'];
        var inner = _.rootScope.context['f'].directive(NgForm);

        expect(inner.name).toEqual('myInnerForm');
        expect(scope.eval('myForm["myInnerForm"]["one"].viewValue')).toEqual('it works!');
      });

      it('should set the validity for the parent form when fieldsets are used', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <fieldset probe="f">' +
                        '    <input type="text" ng-model="one" name="one" probe="m" />' +
                        '  </fieldset>' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        var fieldset = _.rootScope.context['f'].directive(NgForm);
        var model = _.rootScope.context['m'].directive(NgModel);

        model.addError("error");

        expect(model.valid).toBe(false);
        expect(fieldset.valid).toBe(false);
        expect(form.valid).toBe(false);

        model.removeError("error");

        expect(model.valid).toBe(true);
        expect(fieldset.valid).toBe(true);
        expect(form.valid).toBe(true);
      });

      it('should revalidate itself when an inner model is removed', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"><input ng-model="m" ng-if="on" required /></form>');
        _.compile(element);
        scope.context['on'] = true;
        scope.apply();

        var form = scope.context['myForm'];

        expect(form.invalid).toBe(true);

        scope.context['on'] = false;
        scope.apply();

        expect(form.invalid).toBe(false);

        scope.context['on'] = true;
        scope.apply();

        expect(form.invalid).toBe(true);
      });
    });

    describe('controls', () {
      it('should add each contained ng-model as a control upon compile', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="mega_model" name="mega_name" />' +
                        '  <select ng-model="fire_model" name="fire_name">' +
                        '    <option>value</option>'
                        '  </select>' +
                        '</form>');

        _.compile(element);

        scope.context['mega_model'] = 'mega';
        scope.context['fire_model'] = 'fire';
        scope.apply();

        var form = scope.context['myForm'];
        expect(form['mega_name'].modelValue).toBe('mega');
        expect(form['fire_name'].modelValue).toBe('fire');
      });

      it('should properly remove controls directly from the ngForm instance', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="mega_model" name="mega_control" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        var control = form['mega_control'];
        form.removeControl(control);
        expect(form['mega_control']).toBeNull();
      });

      it('should remove all controls when the scope is destroyed', (Scope scope, TestBed _) {
        Scope childScope = scope.createChild({});
        var element = $('<form name="myForm">' +
                        '  <input type="text" ng-model="one" name="one" />' +
                        '  <input type="text" ng-model="two" name="two" />' +
                        '  <input type="text" ng-model="three" name="three" />' +
                        '</form>');

        _.compile(element, scope: childScope);
        childScope.apply();

        var form = childScope.context['myForm'];
        expect(form['one']).toBeDefined();
        expect(form['two']).toBeDefined();
        expect(form['three']).toBeDefined();

        childScope.destroy();

        expect(form['one']).toBeNull();
        expect(form['two']).toBeNull();
        expect(form['three']).toBeNull();
      });

      it('should remove from parent when child is removed', (Scope scope, TestBed _) {
        var element = $('<form name="myForm">' +
                        '  <input type="text" name="mega_name" ng-if="mega_visible" ng-model="value"/>' +
                        '</form>');
        _.compile(element);

        scope.context['mega_visible'] = true;
        scope.apply();

        var form = scope.context['myForm'];
        expect(form['mega_name']).toBeDefined();

        scope.context['mega_visible'] = false;
        scope.apply();
        expect(form['mega_name']).toBeNull();
      });
    });

    describe('onSubmit', () {
      it('should suppress the submission event if no action is provided within the form', (Scope scope, TestBed _) {
        var element = $('<form name="myForm"></form>');

        _.compile(element);
        scope.apply();

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        expect(submissionEvent.defaultPrevented).toBe(false);
        element[0].dispatchEvent(submissionEvent);
        expect(submissionEvent.defaultPrevented).toBe(true);

        Event fakeEvent = new Event.eventType('CustomEvent', 'running');

        expect(fakeEvent.defaultPrevented).toBe(false);
        element[0].dispatchEvent(submissionEvent);
        expect(fakeEvent.defaultPrevented).toBe(false);
      });

      it('should not prevent the submission event if an action is defined', (Scope scope, TestBed _) {
        var element = $('<form name="myForm" action="..."></form>');

        _.compile(element);
        scope.apply();

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        expect(submissionEvent.defaultPrevented).toBe(false);
        element[0].dispatchEvent(submissionEvent);
        expect(submissionEvent.defaultPrevented).toBe(false);
      });

      it('should execute the ng-submit expression if provided upon form submission', (Scope scope, TestBed _) {
        var element = $('<form name="myForm" ng-submit="submitted = true"></form>');

        _.compile(element);
        scope.apply();

        _.rootScope.context['submitted'] = false;

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');
        element[0].dispatchEvent(submissionEvent);

        expect(_.rootScope.context['submitted']).toBe(true);
      });

      it('should apply the valid and invalid prefixed submit CSS classes to the element',
        (TestBed _, Scope scope) {

        _.compile('<form name="superForm">' +
                  ' <input type="text" ng-model="myModel" probe="i" required />' +
                  '</form>');

        NgForm form = _.rootScope.context['superForm'];
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);
        var formElement = form.element.node;

        expect(form.submitted).toBe(false);
        expect(form.valid_submit).toBe(false);
        expect(form.invalid_submit).toBe(false);
        expect(formElement.classes.contains('ng-submit-invalid')).toBe(false);
        expect(formElement.classes.contains('ng-submit-valid')).toBe(false);

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        formElement.dispatchEvent(submissionEvent);
        scope.apply();

        expect(form.submitted).toBe(true);
        expect(form.valid_submit).toBe(false);
        expect(form.invalid_submit).toBe(true);
        expect(formElement.classes.contains('ng-submit-invalid')).toBe(true);
        expect(formElement.classes.contains('ng-submit-valid')).toBe(false);

        _.rootScope.apply('myModel = "man"');
        formElement.dispatchEvent(submissionEvent);
        scope.apply();

        expect(form.submitted).toBe(true);
        expect(form.valid_submit).toBe(true);
        expect(form.invalid_submit).toBe(false);
        expect(formElement.classes.contains('ng-submit-invalid')).toBe(false);
        expect(formElement.classes.contains('ng-submit-valid')).toBe(true);
      });
    });

    describe('error handling', () {
      it('should return true or false depending on if an error exists on a form',
        (Scope scope, TestBed _) {

        var element = $('<form name="myForm">'
                        '  <input type="text" ng-model="input" name="input" />' +
                        '</form>');

        _.compile(element);
        scope.apply();

        var form = scope.context['myForm'];
        NgModel input = form['input'];

        expect(form.hasErrorState('big-failure')).toBe(false);

        input.addError('big-failure');
        input.validate();

        expect(form.hasErrorState('big-failure')).toBe(true);

        input.removeError('big-failure');
        input.validate();

        expect(form.hasErrorState('big-failure')).toBe(false);
      });
    });

    describe('validators', () {
      it('should display the valid and invalid CSS classes on the element for each validation',     
        (TestBed _, Scope scope) {

        var form = _.compile(
          '<form name="myForm">' +
          ' <input type="text" ng-model="myModel" required />' +
          '</form>'
        );

        scope.apply();

        expect(form.classes.contains('ng-required-invalid')).toBe(true);
        expect(form.classes.contains('ng-required-valid')).toBe(false);

        scope.apply(() {
          scope.context['myModel'] = 'value'; 
        });

        expect(form.classes.contains('ng-required-valid')).toBe(true);
        expect(form.classes.contains('ng-required-invalid')).toBe(false);
      });

      describe('custom validators', () {
        beforeEachModule((Module module) {
          module.type(MyCustomFormValidator);
        });

        it('should display the valid and invalid CSS classes on the element for custom validations', (TestBed _, Scope scope) {
          var form = _.compile('<form name="myForm">' +
          ' <input type="text" ng-model="myModel" custom-form-validation />' +
          '</form>');

          scope.apply();

          expect(form.classes.contains('custom-invalid')).toBe(true);
          expect(form.classes.contains('custom-valid')).toBe(false);

          scope.apply(() {
            scope.context['myModel'] = 'yes';
          });

          expect(form.classes.contains('custom-valid')).toBe(true);
          expect(form.classes.contains('custom-invalid')).toBe(false);
        });
      });
    });

    describe('reset()', () {
      it('should reset the model value to its original state', (TestBed _) {
        _.compile('<form name="superForm">' +
                  ' <input type="text" ng-model="myModel" probe="i" />' +
                  '</form>');
        _.rootScope.apply('myModel = "animal"');

        NgForm form = _.rootScope.context['superForm'];

        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');

        _.rootScope.apply('myModel = "man"');

        expect(_.rootScope.context['myModel']).toEqual('man');
        expect(model.modelValue).toEqual('man');
        expect(model.viewValue).toEqual('man');

        form.reset();
        _.rootScope.apply();

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');
      });

      // TODO(matias): special-base form_valid
      it('should set the form control to be untouched when the model is reset',
        (TestBed _, Scope scope) {

        var form = _.compile('<form name="duperForm">' +
                             ' <input type="text" ng-model="myModel" probe="i" />' +
                             '</form>');
        var model = _.rootScope.context['i'].directive(NgModel);
        var input = model.element.node;

        NgForm formModel = _.rootScope.context['duperForm'];
        scope.apply();

        expect(formModel.touched).toBe(false);
        expect(formModel.untouched).toBe(true);
        expect(form.classes.contains('ng-touched')).toBe(false);
        expect(form.classes.contains('ng-untouched')).toBe(true);

        _.triggerEvent(input, 'blur');
        scope.apply();

        expect(formModel.touched).toBe(true);
        expect(formModel.untouched).toBe(false);
        expect(form.classes.contains('ng-touched')).toBe(true);
        expect(form.classes.contains('ng-untouched')).toBe(false);

        formModel.reset();
        scope.apply();

        expect(formModel.touched).toBe(false);
        expect(formModel.untouched).toBe(true);
        expect(form.classes.contains('ng-touched')).toBe(false);
        expect(form.classes.contains('ng-untouched')).toBe(true);

        _.triggerEvent(input, 'blur');

        expect(formModel.touched).toBe(true);
      });

      it('should reset each of the controls to be untouched only when the form has a valid submission', (Scope scope, TestBed _) {
        var form = _.compile('<form name="duperForm">' +
                             ' <input type="text" ng-model="myModel" probe="i" required />' +
                             '</form>');

        NgForm formModel = _.rootScope.context['duperForm'];
        var model = _.rootScope.context['i'].directive(NgModel);
        var input = model.element.node;
        _.triggerEvent(input, 'blur');

        expect(formModel.touched).toBe(true);
        expect(model.touched).toBe(true);
        expect(formModel.invalid).toBe(true);

        _.triggerEvent(form, 'submit');

        expect(formModel.touched).toBe(true);
        expect(model.touched).toBe(true);
        expect(formModel.invalid).toBe(true);

        scope.apply(() {
          scope.context['myModel'] = 'value';
        });
        _.triggerEvent(form, 'submit');

        expect(formModel.valid).toBe(true);
        expect(formModel.touched).toBe(false);
        expect(model.touched).toBe(false);
      });
    });

    it("should use map notation to fetch controls", (TestBed _) {
        Scope s = _.rootScope;
        s.context['name'] = 'cool';

        var form = _.compile('<form name="myForm">' +
                             ' <input type="text" ng-model="someModel" probe="i" name="name" />' +
                             '</form>');

        NgForm formModel = s.context['myForm'];
        Probe probe = s.context['i'];
        var model = probe.directive(NgModel);

        expect(s.eval('name')).toEqual('cool');
        expect(s.eval('myForm.name')).toEqual('myForm');
        expect(s.eval('myForm["name"]')).toBe(model);
        expect(s.eval('myForm["name"].name')).toEqual("name");
    });

    describe('regression tests: form', () {
      beforeEachModule((Module module) {
        module.type(NgForm);
      });

      it('should be resolvable by injector if configured by user.', (Injector injector, Compiler compiler, DirectiveMap directives) {
        var element = $('<form></form>');
        compiler(element, directives)(injector, element);
        // The only expectation is that this doesn't throw
      });
    });
  });
}

@NgDirective(
    selector: '[custom-form-validation]')
class MyCustomFormValidator extends NgValidator {
  MyCustomFormValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  final String name = 'custom';

  bool isValid(name) {
    return name != null && name == 'yes';
  }
}
