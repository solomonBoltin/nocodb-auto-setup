-- Construction Materials Database Schema
-- PostgreSQL Implementation

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS public.material_quantities CASCADE;
DROP TABLE IF EXISTS public.material_variations CASCADE;
DROP TABLE IF EXISTS public.installation_materials CASCADE;
DROP TABLE IF EXISTS public.material_installation_configs CASCADE;
DROP TABLE IF EXISTS public.materials CASCADE;
DROP TABLE IF EXISTS public.unit_types CASCADE;

-- Create Unit Types table
CREATE TABLE public.unit_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('mass', 'length', 'area', 'volume', 'count')),
    conversion_factor DECIMAL(15,6), -- conversion factor to base unit within type
    base_unit BOOLEAN DEFAULT FALSE, -- marks the base unit for each type
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Materials table
CREATE TABLE public.materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'regular' CHECK (type IN ('regular', 'main_material')),
    description TEXT,
    cost_per_unit DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    unit_measure_id INTEGER NOT NULL REFERENCES public.unit_types(id),
    unit_measure_quantity DECIMAL(10,3) NOT NULL DEFAULT 1.0,
    labor_cost_per_unit DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Material Installation Configs table
CREATE TABLE public.material_installation_configs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    material_id INTEGER NOT NULL REFERENCES public.materials(id) ON DELETE CASCADE,
    unit_type_id INTEGER NOT NULL REFERENCES public.unit_types(id),
    labor_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Installation Materials join table (materials needed for installation)
CREATE TABLE public.installation_materials (
    id SERIAL PRIMARY KEY,
    config_id INTEGER NOT NULL REFERENCES public.material_installation_configs(id) ON DELETE CASCADE,
    material_id INTEGER NOT NULL REFERENCES public.materials(id),
    quantity_per_unit DECIMAL(10,3) NOT NULL DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(config_id, material_id)
);

-- Create Material Quantities join table (sub-materials needed for main materials)
CREATE TABLE public.material_quantities (
    id SERIAL PRIMARY KEY,
    parent_material_id INTEGER NOT NULL REFERENCES public.materials(id) ON DELETE CASCADE,
    sub_material_id INTEGER NOT NULL REFERENCES public.materials(id),
    quantity DECIMAL(10,3) NOT NULL DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_material_id, sub_material_id)
);

-- Create Material Variations table
CREATE TABLE public.material_variations (
    id SERIAL PRIMARY KEY,
    material_id INTEGER NOT NULL REFERENCES public.materials(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'single_choice' CHECK (type IN ('single_choice', 'multi_choice', 'numeric_input', 'text_input')),
    required BOOLEAN DEFAULT FALSE,
    options JSONB NOT NULL DEFAULT '[]', -- Array of variation options with modifiers
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_materials_type ON public.materials(type);
CREATE INDEX idx_materials_unit_measure ON public.materials(unit_measure_id);
CREATE INDEX idx_materials_active ON public.materials(is_active);
CREATE INDEX idx_installation_configs_material ON public.material_installation_configs(material_id);
CREATE INDEX idx_installation_materials_config ON public.installation_materials(config_id);
CREATE INDEX idx_installation_materials_material ON public.installation_materials(material_id);
CREATE INDEX idx_material_quantities_parent ON public.material_quantities(parent_material_id);
CREATE INDEX idx_material_quantities_sub ON public.material_quantities(sub_material_id);
CREATE INDEX idx_material_variations_material ON public.material_variations(material_id);
CREATE INDEX idx_unit_types_type ON public.unit_types(type);

-- Add triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON public.materials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_material_installation_configs_updated_at BEFORE UPDATE ON public.material_installation_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_material_variations_updated_at BEFORE UPDATE ON public.material_variations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add constraint to prevent self-referencing in material_quantities
ALTER TABLE public.material_quantities 
ADD CONSTRAINT chk_no_self_reference 
CHECK (parent_material_id != sub_material_id);

-- Add constraint to ensure only one default config per material
CREATE UNIQUE INDEX idx_unique_default_config 
ON public.material_installation_configs(material_id) 
WHERE is_default = TRUE;