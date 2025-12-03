// API Configuration
// Update this with your actual backend URL
export const API_BASE_URL = 'http://10.0.2.2:8000'; // Android emulator
// export const API_BASE_URL = 'http://localhost:8000'; // iOS simulator
// export const API_BASE_URL = 'https://your-production-url.com'; // Production

export const API_ENDPOINTS = {
  // Auth
  LOGIN: '/login_user',
  REGISTER: '/register_new_user',
  FORGOT_PASSWORD: '/forgot_password',
  VERIFY_RESET_CODE: '/verify_reset_code',
  RESET_PASSWORD: '/reset_password',
  
  // User
  GET_USER: '/get_user',
  UPDATE_PROFILE: '/update_profile',
  CHANGE_PASSWORD: '/change_password',
  
  // Houses
  FETCH_HOUSES: '/fetch_houses',
  ADD_HOUSE: '/add_house',
  UPDATE_HOUSE: '/update_house',
  DELETE_HOUSE: '/delete_house',
  GET_USER_HOUSES: '/get_user_houses',
  
  // Favourites
  ADD_TO_FAVOURITES: '/add_to_favourites',
  REMOVE_FROM_FAVOURITES: '/remove_from_favourites',
  GET_FAVOURITES: '/get_favourites',
  
  // Messages
  GET_CONVERSATIONS: '/get_conversations',
  GET_MESSAGES: '/get_messages',
  SEND_MESSAGE: '/send_message',
  GET_UNREAD_COUNT: '/get_unread_message_count',
  MARK_AS_READ: '/mark_conversation_as_read',
};
