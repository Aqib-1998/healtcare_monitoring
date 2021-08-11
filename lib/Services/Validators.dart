abstract class StringValidators{
  bool isValid(String value);
}
class NonEmtptyStringValidator implements StringValidators{
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }

}
class EmailandPasswordValidators
{
  final StringValidators emailValidator = NonEmtptyStringValidator();
  final StringValidators passValidator = NonEmtptyStringValidator();
  final String invalidEmailErrorText = "Email can\ 't be empty";
  final String invalidPasswordErrorText = "Password can\ 't be empty";
}