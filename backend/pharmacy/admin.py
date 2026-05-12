
from django.contrib import admin
from .models import MedicineStock


class MedicineStockAdmin(admin.ModelAdmin):
    list_display  = ('medicine_name', 'quantity', 'unit', 'low_stock_threshold', 'medical_condition', 'last_restocked')
    list_editable = ('quantity',)
    search_fields = ('medicine_name', 'medical_condition')

    def is_low_stock(self, obj):
        return obj.is_low_stock()
    is_low_stock.boolean = True
    is_low_stock.short_description = 'Low Stock?'


admin.site.register(MedicineStock, MedicineStockAdmin)