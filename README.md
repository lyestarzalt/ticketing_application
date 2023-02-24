# Ticketing Website

This is a ticketing website built with Flutter, consisting of two views: a client view for customers to obtain tickets, and a management view for staff to manage the ticketing process.

A demo of the website can be found at <https://ticketing-75603.web.app/#/>

## How to Build and Run

### Setting up the Firebase Project

To use the ticketing application, you'll need to set up a Firebase project and configure the necessary authentication and database settings. The schema for the counters and tickets collections should look like this:

- counters
  - counter1
    - current_ticket: 0
    - is_online: true
    - last_ticket: 6
    - status: true

    add other 3 counters...

- tickets
  - randomID
    - counter_number: null
    - ticket_number: 17
    - timestamp: EPOCH

### To build and run the website, follow these steps

1. Make sure you have Flutter installed. See [Flutter documentation](https://flutter.dev/docs/get-started/install) for installation instructions.

2. Clone the repository:
`git clone https://github.com/lyestarzalt/ticketing_application`
1. Install the required dependencies:
`flutter pub get`

1. Build the website using the following command:
`flutter build web --release`

1. Run the website in Chrome using the following command:
`flutter run -d chrome --release`

## Contributions

Contributions to the ticketing website are welcome. If you have any feature requests, bug reports, or suggestions for improvement, please submit them as issues on the GitHub repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
