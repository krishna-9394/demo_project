class User{
  final String name, branch, email;
  final int roll_no, batch;
  User(this.name, this.roll_no, this.branch, this.email, this.batch);
  Map<String, dynamic> toJson() => {
    "name": name,
    "branch": branch,
    "email": email,
    "roll_no": roll_no,
    "batch": batch,
  };
}