-- Insert default furniture categories
INSERT INTO furniture_categories (name, description) VALUES
('Seating', 'Chairs, sofas, benches, and other seating furniture'),
('Tables', 'Dining tables, coffee tables, side tables, and desks'),
('Storage', 'Bookcases, dressers, wardrobes, and storage solutions'),
('Beds', 'Bed frames, mattresses, and bedroom furniture'),
('Lighting', 'Lamps, chandeliers, and lighting fixtures'),
('Decor', 'Artwork, plants, and decorative accessories');

-- Insert sample furniture items (these would normally come from Amazon API)
INSERT INTO furniture_items (category_id, name, description, price, dimensions, style_tags) VALUES
(
    (SELECT id FROM furniture_categories WHERE name = 'Seating'),
    'Modern Grey Sofa',
    'Contemporary 3-seat sofa in charcoal grey fabric',
    899.99,
    '{"width": 84, "height": 32, "depth": 36}',
    '{"modern", "contemporary", "minimalist"}'
),
(
    (SELECT id FROM furniture_categories WHERE name = 'Tables'),
    'Oak Coffee Table',
    'Solid oak coffee table with storage shelf',
    299.99,
    '{"width": 48, "height": 18, "depth": 24}',
    '{"rustic", "traditional", "farmhouse"}'
),
(
    (SELECT id FROM furniture_categories WHERE name = 'Storage'),
    'Industrial Bookshelf',
    'Metal and wood bookshelf with 5 shelves',
    199.99,
    '{"width": 32, "height": 72, "depth": 12}',
    '{"industrial", "modern", "urban"}'
);