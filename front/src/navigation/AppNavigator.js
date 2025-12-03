import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, FontSizes, FontWeights } from '../constants/theme';
import { useNotifications } from '../services/notificationService';

// Screens
import SplashScreen from '../screens/SplashScreen';
import LoginScreen from '../screens/auth/LoginScreen';
import RegisterScreen from '../screens/auth/RegisterScreen';
import ForgotPasswordScreen from '../screens/auth/ForgotPasswordScreen';
import ProfileScreen from '../screens/auth/ProfileScreen';
import HousesListScreen from '../screens/houses/HousesListScreen';
import HouseDetailsScreen from '../screens/houses/HouseDetailsScreen';
import FavouritesScreen from '../screens/houses/FavouritesScreen';
import MapScreen from '../screens/houses/MapScreen';
import MessageUserScreen from '../screens/messages/MessageUserScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

function TabIcon({ focused, label, icon }) {
  return (
    <View style={styles.tabIcon}>
      <Text style={[styles.tabIconText, focused && styles.tabIconTextActive]}>
        {icon}
      </Text>
      <Text style={[styles.tabLabel, focused && styles.tabLabelActive]}>
        {label}
      </Text>
    </View>
  );
}

function TabIconWithBadge({ focused, label, icon, count }) {
  return (
    <View style={styles.tabIcon}>
      <View>
        <Text style={[styles.tabIconText, focused && styles.tabIconTextActive]}>
          {icon}
        </Text>
        {count > 0 && (
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{count > 9 ? '9+' : count}</Text>
          </View>
        )}
      </View>
      <Text style={[styles.tabLabel, focused && styles.tabLabelActive]}>
        {label}
      </Text>
    </View>
  );
}

function MessagesTabIcon({ focused }) {
  const { unreadCount } = useNotifications();
  return (
    <TabIconWithBadge
      focused={focused}
      label="Messages"
      icon="💬"
      count={unreadCount}
    />
  );
}

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarStyle: styles.tabBar,
        tabBarShowLabel: false,
        headerStyle: styles.header,
        headerTitleStyle: styles.headerTitle,
      }}
    >
      <Tab.Screen
        name="Explore"
        component={HousesListScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon focused={focused} label="Explore" icon="🔍" />
          ),
        }}
      />
      <Tab.Screen
        name="Favourites"
        component={FavouritesScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon focused={focused} label="Favourites" icon="❤️" />
          ),
        }}
      />
      <Tab.Screen
        name="Map"
        component={MapScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon focused={focused} label="Map" icon="🗺️" />
          ),
        }}
      />
      <Tab.Screen
        name="Messages"
        component={MessageUserScreen}
        options={{
          tabBarIcon: ({ focused }) => <MessagesTabIcon focused={focused} />,
          headerShown: false,
        }}
        initialParams={{ userId: 0, userName: 'Messages', houseId: null }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon focused={focused} label="Profile" icon="👤" />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
        }}
      >
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Register" component={RegisterScreen} />
        <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
        <Stack.Screen
          name="Main"
          component={MainTabs}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="HouseDetails"
          component={HouseDetailsScreen}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="MessageUser"
          component={MessageUserScreen}
          options={{ headerShown: false }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: Colors.surface,
    borderTopWidth: 1,
    borderTopColor: Colors.border,
    height: 65,
    paddingBottom: 8,
    paddingTop: 8,
  },
  tabIcon: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  tabIconText: {
    fontSize: 24,
    marginBottom: 4,
  },
  tabIconTextActive: {
    transform: [{ scale: 1.1 }],
  },
  tabLabel: {
    fontSize: 11,
    color: Colors.textSecondary,
    fontWeight: FontWeights.medium,
  },
  tabLabelActive: {
    color: Colors.primary,
    fontWeight: FontWeights.semibold,
  },
  badge: {
    position: 'absolute',
    top: -4,
    right: -8,
    backgroundColor: Colors.error,
    borderRadius: 10,
    minWidth: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 4,
  },
  badgeText: {
    color: Colors.surface,
    fontSize: 11,
    fontWeight: FontWeights.bold,
  },
  header: {
    backgroundColor: Colors.surface,
    elevation: 0,
    shadowOpacity: 0,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  headerTitle: {
    fontSize: FontSizes.lg,
    fontWeight: FontWeights.semibold,
    color: Colors.textDark,
  },
});
