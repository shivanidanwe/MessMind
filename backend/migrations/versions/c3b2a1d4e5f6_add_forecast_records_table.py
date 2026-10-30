"""Add forecast_records table

Revision ID: c3b2a1d4e5f6
Revises: b2a1c3d4e5f6
Create Date: 2026-03-01 13:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'c3b2a1d4e5f6'
down_revision = 'b2a1c3d4e5f6'
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        'forecast_records',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('mess_id', sa.String(length=36), nullable=False),
        sa.Column('menu_id', sa.String(length=36), nullable=True),
        sa.Column('forecast_date', sa.Date(), nullable=False),
        sa.Column('meal_type', sa.String(length=50), nullable=False),
        sa.Column('predicted_demand', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('recommended_quantity', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('actual_demand', sa.Integer(), nullable=True),
        sa.Column('model_name', sa.String(length=100), nullable=False, server_default='RandomForestRegressor'),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['mess_id'], ['messes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['menu_id'], ['menus.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_forecast_records_forecast_date'), 'forecast_records', ['forecast_date'], unique=False)
    op.create_index(op.f('ix_forecast_records_mess_id'), 'forecast_records', ['mess_id'], unique=False)

def downgrade() -> None:
    op.drop_index(op.f('ix_forecast_records_mess_id'), table_name='forecast_records')
    op.drop_index(op.f('ix_forecast_records_forecast_date'), table_name='forecast_records')
    op.drop_table('forecast_records')
