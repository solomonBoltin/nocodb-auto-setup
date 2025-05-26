-- Construction Materials Database Seed Data
-- PostgreSQL Implementation

-- Seed Unit Types
INSERT INTO public.unit_types (name, type, conversion_factor, base_unit) VALUES
-- Mass units (base: kg)
('kg', 'mass', 1.0, TRUE),
('g', 'mass', 0.001, FALSE),
('ton', 'mass', 1000.0, FALSE),
('lb', 'mass', 0.453592, FALSE),

-- Length units (base: meter)
('meter', 'length', 1.0, TRUE),
('cm', 'length', 0.01, FALSE),
('mm', 'length', 0.001, FALSE),
('foot', 'length', 0.3048, FALSE),
('inch', 'length', 0.0254, FALSE),
('yard', 'length', 0.9144, FALSE),

-- Area units (base: m2)
('m2', 'area', 1.0, TRUE),
('cm2', 'area', 0.0001, FALSE),
('foot2', 'area', 0.092903, FALSE),
('inch2', 'area', 0.00064516, FALSE),

-- Volume units (base: m3)
('m3', 'volume', 1.0, TRUE),
('liter', 'volume', 0.001, FALSE),
('gallon', 'volume', 0.00378541, FALSE),
('foot3', 'volume', 0.0283168, FALSE),

-- Count units
('piece', 'count', 1.0, TRUE),
('dozen', 'count', 12.0, FALSE),
('hundred', 'count', 100.0, FALSE),
('thousand', 'count', 1000.0, FALSE);

-- Seed Main Materials
INSERT INTO public.materials (name, type, description, cost_per_unit, unit_measure_id, unit_measure_quantity, labor_cost_per_unit) VALUES
-- Main construction materials
('Concrete Mix', 'main_material', 'Ready-mix concrete for foundation and structure', 85.00, 
 (SELECT id FROM public.unit_types WHERE name = 'm3'), 1.0, 25.00),

('Steel Rebar', 'main_material', 'Reinforcement steel bars for concrete structures', 650.00, 
 (SELECT id FROM public.unit_types WHERE name = 'ton'), 1.0, 150.00),

('Lumber 2x4', 'main_material', 'Standard construction lumber', 4.50, 
 (SELECT id FROM public.unit_types WHERE name = 'foot'), 8.0, 0.75),

('Lumber 2x6', 'main_material', 'Standard construction lumber', 6.75, 
 (SELECT id FROM public.unit_types WHERE name = 'foot'), 8.0, 0.85),

('Plywood Sheathing', 'main_material', '3/4 inch plywood for structural sheathing', 45.00, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 32.0, 2.25),

('Drywall', 'main_material', '1/2 inch gypsum board', 12.00, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 32.0, 1.50),

('Insulation Fiberglass', 'main_material', 'R-15 fiberglass batt insulation', 0.85, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 1.0, 0.25),

('Roof Shingles', 'main_material', 'Asphalt composition shingles', 120.00, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 100.0, 3.50),

('Vinyl Siding', 'main_material', 'Exterior vinyl siding panels', 3.25, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 1.0, 1.75),

('Flooring Hardwood', 'main_material', 'Oak hardwood flooring strips', 8.50, 
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 1.0, 4.25);

-- Seed Installation/Fastening Materials
INSERT INTO public.materials (name, type, description, cost_per_unit, unit_measure_id, unit_measure_quantity, labor_cost_per_unit) VALUES
-- Fasteners and installation materials
('Concrete Screws', 'regular', 'Masonry screws for concrete attachment', 0.35, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.05),

('Wood Screws 2.5"', 'regular', 'Self-drilling wood screws', 0.12, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.02),

('Wood Screws 3"', 'regular', 'Self-drilling wood screws', 0.15, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.02),

('Framing Nails', 'regular', '3.5 inch common nails for framing', 0.08, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.01),

('Roofing Nails', 'regular', 'Galvanized roofing nails', 0.06, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.01),

('Construction Adhesive', 'regular', 'Polyurethane construction adhesive', 8.50, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.0),

('Drywall Compound', 'regular', 'Joint compound for drywall finishing', 15.00, 
 (SELECT id FROM public.unit_types WHERE name = 'gallon'), 1.0, 0.0),

('Drywall Tape', 'regular', 'Paper tape for drywall joints', 12.00, 
 (SELECT id FROM public.unit_types WHERE name = 'foot'), 500.0, 0.0),

('Primer Paint', 'regular', 'Latex primer for interior surfaces', 35.00, 
 (SELECT id FROM public.unit_types WHERE name = 'gallon'), 1.0, 0.0),

('Caulk Silicone', 'regular', 'Silicone sealant for weatherproofing', 4.50, 
 (SELECT id FROM public.unit_types WHERE name = 'piece'), 1.0, 0.0);

-- Seed Installation Configurations
INSERT INTO public.material_installation_configs (name, material_id, unit_type_id, labor_rate, is_default) VALUES
('Standard Concrete Pour', 
 (SELECT id FROM public.materials WHERE name = 'Concrete Mix'),
 (SELECT id FROM public.unit_types WHERE name = 'm3'), 
 25.00, TRUE),

('Rebar Installation', 
 (SELECT id FROM public.materials WHERE name = 'Steel Rebar'),
 (SELECT id FROM public.unit_types WHERE name = 'ton'), 
 150.00, TRUE),

('Framing Installation', 
 (SELECT id FROM public.materials WHERE name = 'Lumber 2x4'),
 (SELECT id FROM public.unit_types WHERE name = 'foot'), 
 0.75, TRUE),

('Heavy Framing Installation', 
 (SELECT id FROM public.materials WHERE name = 'Lumber 2x6'),
 (SELECT id FROM public.unit_types WHERE name = 'foot'), 
 0.85, TRUE),

('Sheathing Installation', 
 (SELECT id FROM public.materials WHERE name = 'Plywood Sheathing'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 2.25, TRUE),

('Drywall Installation', 
 (SELECT id FROM public.materials WHERE name = 'Drywall'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 1.50, TRUE),

('Insulation Installation', 
 (SELECT id FROM public.materials WHERE name = 'Insulation Fiberglass'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 0.25, TRUE),

('Roofing Installation', 
 (SELECT id FROM public.materials WHERE name = 'Roof Shingles'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 3.50, TRUE),

('Siding Installation', 
 (SELECT id FROM public.materials WHERE name = 'Vinyl Siding'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 1.75, TRUE),

('Hardwood Flooring Installation', 
 (SELECT id FROM public.materials WHERE name = 'Flooring Hardwood'),
 (SELECT id FROM public.unit_types WHERE name = 'foot2'), 
 4.25, TRUE);

-- Seed Installation Materials (materials needed for installation)
INSERT INTO public.installation_materials (config_id, material_id, quantity_per_unit) VALUES
-- Concrete installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Standard Concrete Pour'),
 (SELECT id FROM public.materials WHERE name = 'Steel Rebar'), 0.15),

-- Framing installation materials  
((SELECT id FROM public.material_installation_configs WHERE name = 'Framing Installation'),
 (SELECT id FROM public.materials WHERE name = 'Framing Nails'), 8),

((SELECT id FROM public.material_installation_configs WHERE name = 'Heavy Framing Installation'),
 (SELECT id FROM public.materials WHERE name = 'Framing Nails'), 12),

-- Sheathing installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Sheathing Installation'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 2.5"'), 0.5),

((SELECT id FROM public.material_installation_configs WHERE name = 'Sheathing Installation'),
 (SELECT id FROM public.materials WHERE name = 'Construction Adhesive'), 0.01),

-- Drywall installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Drywall Installation'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 2.5"'), 0.25),

((SELECT id FROM public.material_installation_configs WHERE name = 'Drywall Installation'),
 (SELECT id FROM public.materials WHERE name = 'Drywall Compound'), 0.02),

((SELECT id FROM public.material_installation_configs WHERE name = 'Drywall Installation'),
 (SELECT id FROM public.materials WHERE name = 'Drywall Tape'), 0.1),

-- Roofing installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Roofing Installation'),
 (SELECT id FROM public.materials WHERE name = 'Roofing Nails'), 2.5),

-- Siding installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Siding Installation'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 3"'), 1.2),

((SELECT id FROM public.material_installation_configs WHERE name = 'Siding Installation'),
 (SELECT id FROM public.materials WHERE name = 'Caulk Silicone'), 0.005),

-- Hardwood flooring installation materials
((SELECT id FROM public.material_installation_configs WHERE name = 'Hardwood Flooring Installation'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 2.5"'), 3.0),

((SELECT id FROM public.material_installation_configs WHERE name = 'Hardwood Flooring Installation'),
 (SELECT id FROM public.materials WHERE name = 'Construction Adhesive'), 0.02);

-- Seed Material Quantities (sub-materials for composite materials)
INSERT INTO public.material_quantities (parent_material_id, sub_material_id, quantity) VALUES
-- Composite lumber packages that include fasteners
((SELECT id FROM public.materials WHERE name = 'Plywood Sheathing'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 2.5"'), 16),

((SELECT id FROM public.materials WHERE name = 'Drywall'),
 (SELECT id FROM public.materials WHERE name = 'Wood Screws 2.5"'), 8),

((SELECT id FROM public.materials WHERE name = 'Drywall'),
 (SELECT id FROM public.materials WHERE name = 'Drywall Tape'), 3.2);

-- Seed Material Variations
INSERT INTO public.material_variations (material_id, name, type, required, options) VALUES
-- Concrete variations
((SELECT id FROM public.materials WHERE name = 'Concrete Mix'),
 'Strength Grade', 'single_choice', TRUE, 
 '[
   {"label": "Standard (20 MPa)", "value": "20mpa", "price_modifier": 1.0},
   {"label": "High Strength (25 MPa)", "value": "25mpa", "price_modifier": 1.15},
   {"label": "Extra High (30 MPa)", "value": "30mpa", "price_modifier": 1.35}
 ]'),

((SELECT id FROM public.materials WHERE name = 'Concrete Mix'),
 'Additives', 'multi_choice', FALSE, 
 '[
   {"label": "Fiber Reinforcement", "value": "fiber", "price_add": 8.50},
   {"label": "Accelerator", "value": "accelerator", "price_add": 12.00},
   {"label": "Water Reducer", "value": "water_reducer", "price_add": 6.75}
 ]'),

-- Lumber variations
((SELECT id FROM public.materials WHERE name = 'Lumber 2x4'),
 'Grade', 'single_choice', TRUE, 
 '[
   {"label": "Construction Grade", "value": "construction", "price_modifier": 1.0},
   {"label": "Stud Grade", "value": "stud", "price_modifier": 1.15},
   {"label": "Select Structural", "value": "select", "price_modifier": 1.45}
 ]'),

((SELECT id FROM public.materials WHERE name = 'Lumber 2x4'),
 'Treatment', 'single_choice', FALSE, 
 '[
   {"label": "Untreated", "value": "none", "price_modifier": 1.0},
   {"label": "Pressure Treated", "value": "treated", "price_modifier": 1.25},
   {"label": "Kiln Dried", "value": "kiln_dried", "price_modifier": 1.18}
 ]'),

-- Insulation variations
((SELECT id FROM public.materials WHERE name = 'Insulation Fiberglass'),
 'R-Value', 'single_choice', TRUE, 
 '[
   {"label": "R-11", "value": "r11", "price_modifier": 0.85},
   {"label": "R-15", "value": "r15", "price_modifier": 1.0},
   {"label": "R-19", "value": "r19", "price_modifier": 1.25},
   {"label": "R-21", "value": "r21", "price_modifier": 1.45}
 ]'),

-- Roofing variations
((SELECT id FROM public.materials WHERE name = 'Roof Shingles'),
 'Style', 'single_choice', TRUE, 
 '[
   {"label": "3-Tab", "value": "3tab", "price_modifier": 1.0},
   {"label": "Architectural", "value": "architectural", "price_modifier": 1.35},
   {"label": "Premium", "value": "premium", "price_modifier": 1.75}
 ]'),

((SELECT id FROM public.materials WHERE name = 'Roof Shingles'),
 'Color', 'single_choice', TRUE, 
 '[
   {"label": "Charcoal", "value": "charcoal", "price_modifier": 1.0},
   {"label": "Brown", "value": "brown", "price_modifier": 1.0},
   {"label": "Gray", "value": "gray", "price_modifier": 1.0},
   {"label": "Designer Colors", "value": "designer", "price_modifier": 1.15}
 ]'),

-- Siding variations
((SELECT id FROM public.materials WHERE name = 'Vinyl Siding'),
 'Profile', 'single_choice', TRUE, 
 '[
   {"label": "Dutch Lap", "value": "dutch_lap", "price_modifier": 1.0},
   {"label": "Clapboard", "value": "clapboard", "price_modifier": 1.08},
   {"label": "Board & Batten", "value": "board_batten", "price_modifier": 1.25}
 ]'),

-- Hardwood flooring variations
((SELECT id FROM public.materials WHERE name = 'Flooring Hardwood'),
 'Wood Species', 'single_choice', TRUE, 
 '[
   {"label": "Oak", "value": "oak", "price_modifier": 1.0},
   {"label": "Maple", "value": "maple", "price_modifier": 1.15},
   {"label": "Cherry", "value": "cherry", "price_modifier": 1.65},
   {"label": "Walnut", "value": "walnut", "price_modifier": 2.25}
 ]'),

((SELECT id FROM public.materials WHERE name = 'Flooring Hardwood'),
 'Finish', 'single_choice', TRUE, 
 '[
   {"label": "Pre-finished", "value": "prefinished", "price_modifier": 1.0, "labor_modifier": 0.85},
   {"label": "Unfinished", "value": "unfinished", "price_modifier": 0.75, "labor_modifier": 1.35}
 ]');

-- Create some helpful views
CREATE VIEW public.material_details AS
SELECT 
    m.id,
    m.name,
    m.type,
    m.description,
    m.cost_per_unit,
    ut.name AS unit_measure,
    ut.type AS unit_type,
    m.unit_measure_quantity,
    m.labor_cost_per_unit,
    m.is_active,
    COALESCE(mv.variation_count, 0) AS variation_count,
    COALESCE(ic.config_count, 0) AS installation_config_count
FROM public.materials m
JOIN public.unit_types ut ON m.unit_measure_id = ut.id
LEFT JOIN (
    SELECT material_id, COUNT(*) AS variation_count
    FROM public.material_variations
    GROUP BY material_id
) mv ON m.id = mv.material_id
LEFT JOIN (
    SELECT material_id, COUNT(*) AS config_count
    FROM public.material_installation_configs
    GROUP BY material_id
) ic ON m.id = ic.material_id;

CREATE VIEW public.installation_config_details AS
SELECT 
    mic.id,
    mic.name AS config_name,
    m.name AS material_name,
    m.type AS material_type,
    ut.name AS labor_unit,
    mic.labor_rate,
    mic.is_default,
    COALESCE(im.material_count, 0) AS required_materials_count
FROM public.material_installation_configs mic
JOIN public.materials m ON mic.material_id = m.id
JOIN public.unit_types ut ON mic.unit_type_id = ut.id
LEFT JOIN (
    SELECT config_id, COUNT(*) AS material_count
    FROM public.installation_materials
    GROUP BY config_id
) im ON mic.id = im.config_id;