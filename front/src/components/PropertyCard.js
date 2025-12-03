import React from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { Colors, Spacing, BorderRadius, FontSizes, FontWeights, Shadows } from '../constants/theme';

export default function PropertyCard({ property, onPress }) {
  const getImages = () => {
    if (!property.house_picture) return [];
    
    if (typeof property.house_picture === 'string') {
      try {
        return JSON.parse(property.house_picture);
      } catch (e) {
        return [];
      }
    }
    
    if (Array.isArray(property.house_picture)) {
      return property.house_picture;
    }
    
    return [];
  };

  const images = getImages();
  const firstImage = images.length > 0 ? images[0] : null;

  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      {firstImage ? (
        <Image source={{ uri: firstImage }} style={styles.image} />
      ) : (
        <View style={[styles.image, styles.imagePlaceholder]}>
          <Text style={styles.placeholderText}>No Image</Text>
        </View>
      )}
      
      <View style={styles.statusBadge}>
        <Text style={styles.statusText}>
          {property.status?.toUpperCase() || 'N/A'}
        </Text>
      </View>

      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={1}>
          {property.name || 'Unnamed Property'}
        </Text>
        
        <Text style={styles.price}>${property.price || '0'}</Text>
        
        <View style={styles.details}>
          <Text style={styles.detailText}>
            🛏️ {property.rooms || 0} {property.rooms === 1 ? 'Room' : 'Rooms'}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    marginBottom: Spacing.md,
    ...Shadows.medium,
    overflow: 'hidden',
  },
  image: {
    width: '100%',
    height: 200,
    backgroundColor: Colors.borderLight,
  },
  imagePlaceholder: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderText: {
    color: Colors.textLight,
    fontSize: FontSizes.md,
  },
  statusBadge: {
    position: 'absolute',
    top: Spacing.sm,
    right: Spacing.sm,
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.xs,
  },
  statusText: {
    color: Colors.surface,
    fontSize: FontSizes.xs,
    fontWeight: FontWeights.bold,
  },
  content: {
    padding: Spacing.md,
  },
  title: {
    fontSize: FontSizes.lg,
    fontWeight: FontWeights.semibold,
    color: Colors.textDark,
    marginBottom: Spacing.xs,
  },
  price: {
    fontSize: FontSizes.xl,
    fontWeight: FontWeights.bold,
    color: Colors.primary,
    marginBottom: Spacing.sm,
  },
  details: {
    flexDirection: 'row',
  },
  detailText: {
    fontSize: FontSizes.sm,
    color: Colors.textSecondary,
    fontWeight: FontWeights.medium,
  },
});
