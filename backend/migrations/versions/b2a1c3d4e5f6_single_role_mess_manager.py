"""Single Role MESS_MANAGER migration

Revision ID: b2a1c3d4e5f6
Revises: efab6066546c
Create Date: 2026-03-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'b2a1c3d4e5f6'
down_revision = 'efab6066546c'
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Safely update existing user roles to MESS_MANAGER without deleting accounts or operational data
    op.execute("UPDATE users SET role = 'MESS_MANAGER' WHERE role IN ('ADMIN', 'MANAGER', 'STAFF');")

def downgrade() -> None:
    op.execute("UPDATE users SET role = 'MANAGER' WHERE role = 'MESS_MANAGER';")
