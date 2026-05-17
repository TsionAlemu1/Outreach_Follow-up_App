# Outreach Follow-up App

A Flutter mobile application for managing university fellowship outreach and follow-up activities.

This project was developed as part of a CRUD API consumption assignment using Flutter, Provider state management, and the HTTP package.

---

## Features

- View outreach follow-up records
- Add new outreach contacts
- Update follow-up status
- Delete outreach records
- Manage outreach notes
- Clean and responsive UI
- Loading and error handling states
- REST API integration

---

## Technologies Used

- Flutter
- Dart
- Provider State Management
- HTTP Package
- REST API (JSONPlaceholder)

---

## Project Structure

```bash
lib/
│
├── models/
├── providers/
├── services/
├── screens/
├── widgets/
└── utils/
```

---

## API Used

This project uses the public REST API from:

https://jsonplaceholder.typicode.com/

---

## CRUD Operations

| Operation | HTTP Method |
| --------- | ----------- |
| Create    | POST        |
| Read      | GET         |
| Update    | PUT/PATCH   |
| Delete    | DELETE      |

---

## Screenshots

### Home Screen

![alt text](<Screenshot 2026-05-17 145548.png>)

### Add Person Screen

![alt text](Add_people.png)

### Detail Screen

![alt text](Detail_page.png)

### Edit Screen

![alt text](Edit_page.png)

### Delete page

![alt text](Delet_page.png)

### Delete confirm

![alt text](image.png)

## Follow up reminder

![alt text](image-1.png)

### Add followup

![alt text](image-2.png)

### Edit follow-up

![alt text](image-3.png)

### Clone the repository

```bash
git clone https://github.com/TsionAlemu1/Outreach_Follow-up_App.git
```

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

---

## Dependencies

```yaml
provider:
http:
```

---

## Author

Developed by [Tsion Alemu]

---

## Assignment Requirements Covered

- CRUD API consumption
- HTTP package integration
- Provider state management
- Clean project structure
- Error handling
- Loading states
- GitHub repository management
