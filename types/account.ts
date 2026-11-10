export interface UserProfile {
  name: string;
  email: string;
  phone: string;
  avatar: string; // e.g. "asset:people/person_0.png"
}

export interface Address {
  id: string;
  label: string;
  line: string;
}

export interface AppNotification {
  id: string;
  title: string;
  body: string;
  minutesAgo: number;
  read: boolean;
}
