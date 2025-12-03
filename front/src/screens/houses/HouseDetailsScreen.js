import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { Colors, Spacing, BorderRadius, FontSizes, FontWeights, Shadows } from '../../constants/theme';
import apiService from '../../services/apiService';

const { width } = Dimensions.get('window');

export default function HouseDetailsScreen({ route, navigation }) {
  const { house } = route.params;
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [isFavourite, setIsFavourite] = useState(house.is_favourite || false);
  const [isLoadingFavourite, setIsLoadingFavourite] = useState(false);
  const scrollViewRef = useRef(null);

  const getImages = () => {
    if (!house.house_picture) return [];
    
    if (typeof house.house_picture === 'string') {
      try {
        return JSON.parse(house.house_picture);
      } catch (e) {
        return [];
      }
    }
    
    if (Array.isArray(house.house_picture)) {
      return house.house_picture;
    }
    
    return [];
  };

  const images = getImages();
  const owner = house.owner || {};

  const toggleFavourite = async () => {
    setIsLoadingFavourite(true);
    try {
      if (isFavourite) {
        await apiService.removeFromFavourites(house.id);
        Alert.alert('Success', 'Removed from favourites');
      } else {
        await apiService.addToFavourites(house.id);
        Alert.alert('Success', 'Added to favourites');
      }
      setIsFavourite(!isFavourite);
    } catch (error) {
      Alert.alert('Error', 'Failed to update favourites');
    } finally {
      setIsLoadingFavourite(false);
    }
  };

  const handleScroll = (event) => {
    const slideSize = event.nativeEvent.layoutMeasurement.width;
    const index = event.nativeEvent.contentOffset.x / slideSize;
    setCurrentImageIndex(Math.round(index));
  };

  return (
    <View style={styles.container}>
      <ScrollView>
        {/* Image Carousel */}
        <View style={styles.imageContainer}>
          {images.length > 0 ? (
            <>
              <ScrollView
                ref={scrollViewRef}
                horizontal
                pagingEnabled
                showsHorizontalScrollIndicator={false}
                onScroll={handleScroll}
                scrollEventThrottle={16}
              >
                {images.map((img, index) => (
                  <Image
                    key={index}
                    source={{ uri: img }}
                    style={styles.image}
                  />
                ))}
              </ScrollView>
              
              <View style={styles.pagination}>
                {images.map((_, index) => (
                  <View
                    key={index}
                    style={[
                      styles.paginationDot,
                      currentImageIndex === index && styles.paginationDotActive,
                    ]}
                  />
                ))}
              </View>
            </>
          ) : (
            <View style={styles.noImageContainer}>
              <Text style={styles.noImageText}>No images available</Text>
            </View>
          )}

          {/* Back and Favourite Buttons */}
          <View style={styles.headerButtons}>
            <TouchableOpacity
              style={styles.headerButton}
              onPress={() => navigation.goBack()}
            >
              <Text style={styles.headerButtonIcon}>←</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.headerButton, isFavourite && styles.favouriteActive]}
              onPress={toggleFavourite}
              disabled={isLoadingFavourite}
            >
              {isLoadingFavourite ? (
                <ActivityIndicator size="small" color={Colors.primary} />
              ) : (
                <Text style={styles.headerButtonIcon}>
                  {isFavourite ? '❤️' : '🤍'}
                </Text>
              )}
            </TouchableOpacity>
          </View>
        </View>

        {/* Property Details */}
        <View style={styles.content}>
          <View style={styles.statusBadge}>
            <Text style={styles.statusText}>
              {house.status?.toUpperCase() || 'N/A'}
            </Text>
          </View>

          <Text style={styles.title}>{house.name || 'Unnamed Property'}</Text>
          <Text style={styles.price}>${house.price || '0'}</Text>

          <View style={styles.detailsRow}>
            <View style={styles.detailItem}>
              <Text style={styles.detailLabel}>Rooms</Text>
              <Text style={styles.detailValue}>{house.rooms || 0}</Text>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Description</Text>
            <Text style={styles.description}>
              {house.description || 'No description available'}
            </Text>
          </View>

          {/* Owner Info */}
          {owner.user_id && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Owner</Text>
              <View style={styles.ownerCard}>
                {owner.profile_picture ? (
                  <Image
                    source={{ uri: owner.profile_picture }}
                    style={styles.ownerImage}
                  />
                ) : (
                  <View style={[styles.ownerImage, styles.ownerImagePlaceholder]}>
                    <Text style={styles.ownerImageText}>
                      {owner.full_name?.[0] || 'U'}
                    </Text>
                  </View>
                )}
                <View style={styles.ownerInfo}>
                  <Text style={styles.ownerName}>{owner.full_name || 'Unknown'}</Text>
                  {owner.email && (
                    <Text style={styles.ownerContact}>{owner.email}</Text>
                  )}
                  {owner.phone_number && (
                    <Text style={styles.ownerContact}>{owner.phone_number}</Text>
                  )}
                </View>
              </View>

              <TouchableOpacity
                style={styles.messageButton}
                onPress={() =>
                  navigation.navigate('MessageUser', {
                    userId: owner.user_id,
                    userName: owner.full_name,
                    houseId: house.id,
                  })
                }
              >
                <Text style={styles.messageButtonText}>Message Owner</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  imageContainer: {
    height: 300,
    position: 'relative',
  },
  image: {
    width,
    height: 300,
  },
  noImageContainer: {
    width,
    height: 300,
    backgroundColor: Colors.borderLight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noImageText: {
    color: Colors.textLight,
    fontSize: FontSizes.md,
  },
  pagination: {
    position: 'absolute',
    bottom: Spacing.md,
    flexDirection: 'row',
    alignSelf: 'center',
  },
  paginationDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255,255,255,0.5)',
    marginHorizontal: 4,
  },
  paginationDotActive: {
    backgroundColor: Colors.surface,
    width: 24,
  },
  headerButtons: {
    position: 'absolute',
    top: Spacing.md,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
  },
  headerButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...Shadows.medium,
  },
  favouriteActive: {
    backgroundColor: Colors.primary,
  },
  headerButtonIcon: {
    fontSize: 20,
  },
  content: {
    padding: Spacing.md,
  },
  statusBadge: {
    alignSelf: 'flex-start',
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.xs,
    marginBottom: Spacing.sm,
  },
  statusText: {
    color: Colors.surface,
    fontSize: FontSizes.xs,
    fontWeight: FontWeights.bold,
  },
  title: {
    fontSize: FontSizes.xxl,
    fontWeight: FontWeights.bold,
    color: Colors.textDark,
    marginBottom: Spacing.sm,
  },
  price: {
    fontSize: FontSizes.xl,
    fontWeight: FontWeights.bold,
    color: Colors.primary,
    marginBottom: Spacing.md,
  },
  detailsRow: {
    flexDirection: 'row',
    marginBottom: Spacing.lg,
  },
  detailItem: {
    flex: 1,
    backgroundColor: Colors.surface,
    padding: Spacing.md,
    borderRadius: BorderRadius.sm,
    ...Shadows.small,
  },
  detailLabel: {
    fontSize: FontSizes.sm,
    color: Colors.textSecondary,
    marginBottom: Spacing.xs,
  },
  detailValue: {
    fontSize: FontSizes.lg,
    fontWeight: FontWeights.bold,
    color: Colors.textDark,
  },
  section: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    fontSize: FontSizes.lg,
    fontWeight: FontWeights.bold,
    color: Colors.textDark,
    marginBottom: Spacing.sm,
  },
  description: {
    fontSize: FontSizes.md,
    color: Colors.textSecondary,
    lineHeight: 22,
  },
  ownerCard: {
    flexDirection: 'row',
    backgroundColor: Colors.surface,
    padding: Spacing.md,
    borderRadius: BorderRadius.sm,
    marginBottom: Spacing.md,
    ...Shadows.small,
  },
  ownerImage: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginRight: Spacing.md,
  },
  ownerImagePlaceholder: {
    backgroundColor: Colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  ownerImageText: {
    fontSize: FontSizes.lg,
    fontWeight: FontWeights.bold,
    color: Colors.surface,
  },
  ownerInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  ownerName: {
    fontSize: FontSizes.md,
    fontWeight: FontWeights.bold,
    color: Colors.textDark,
    marginBottom: Spacing.xs,
  },
  ownerContact: {
    fontSize: FontSizes.sm,
    color: Colors.textSecondary,
  },
  messageButton: {
    backgroundColor: Colors.primary,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.sm,
    alignItems: 'center',
    ...Shadows.medium,
  },
  messageButtonText: {
    color: Colors.surface,
    fontSize: FontSizes.md,
    fontWeight: FontWeights.semibold,
  },
});
