import 'package:equatable/equatable.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/contacts/app_contact.dart';

enum ContactsStateStatus { init, loading, done, failed, noPermission }
enum ChatsStateStatus { init, loading, done }

class SearchState extends Equatable {
  final String searchTerm;

  final ContactsStateStatus contactsStateStatus;
  final ChatsStateStatus chatsStateStatus;
  final List<AppContact> contacts;
  final List<Account> users;
  final List<Account> recentChats;

  const SearchState(
      {required this.searchTerm,
      required this.users,
      required this.recentChats,
      required this.contactsStateStatus,
      required this.chatsStateStatus,
      required this.contacts});

  factory SearchState.initial() {
    return SearchState(
        searchTerm: '',
        contactsStateStatus: ContactsStateStatus.init,
        users: [],
        recentChats: [],
        chatsStateStatus: ChatsStateStatus.init,
        contacts: []);
  }

  SearchState copyWith({
    final String? searchTerm,
    final ContactsStateStatus? contactsStateStatus,
    final List<AppContact>? contacts,
    final List<Account>? users,
    final List<Account>? recentChats,
    final ChatsStateStatus? chatsStateStatus,
  }) {
    return SearchState(
      searchTerm: searchTerm ?? this.searchTerm,
      contactsStateStatus: contactsStateStatus ?? this.contactsStateStatus,
      contacts: contacts ?? this.contacts,
      users: users ?? this.users,
      recentChats: recentChats ?? this.recentChats,
      chatsStateStatus: chatsStateStatus ?? this.chatsStateStatus,
    );
  }

  List<AppContact> getFilteredContacts() {
    if (searchTerm.isEmpty) {
      return contacts;
    }

    return contacts
        .where((contact) =>
            contact.localContact.displayName.toLowerCase().contains(searchTerm))
        .toList();
  }

  @override
  List<Object?> get props => [
        searchTerm,
        contacts,
        contactsStateStatus,
      ];
}
