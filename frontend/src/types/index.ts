export interface RepurposeRequest {
  text: string;
  platforms: string[];
  link?: string;
}

export interface RepurposeResponse {
  posts: Record<string, string>;
}

export interface Platform {
  id: string;
  name: string;
  color: string;
}

export const PLATFORMS: Platform[] = [
  { id: 'twitter', name: 'Twitter/X', color: 'text-black' },
  { id: 'linkedin', name: 'LinkedIn', color: 'text-blue-600' },
  { id: 'instagram', name: 'Instagram', color: 'text-pink-600' },
  { id: 'facebook', name: 'Facebook', color: 'text-blue-700' },
  { id: 'bluesky', name: 'Bluesky', color: 'text-sky-500' },
];

// Meta-description is always included, not selectable
export const META_DESCRIPTION_PLATFORM: Platform = {
  id: 'meta-description',
  name: 'Meta-Description',
  color: 'text-purple-600',
};
