SMART COOLING EXPERTS — ULTIMATE PRO 2026.10.04

اس ZIP میں تین اہم فائلیں ہیں:

1) index.html
   مکمل نیا GitHub Pages فرنٹ اینڈ۔
   Customer Portal، Owner/Admin، Technician، QR، Tracking، Dashboard، Service، Sales،
   Customers، Payments، Warranty، Photos، Inventory، Live Location اور Visit Log شامل ہیں۔

2) supabase_setup.sql
   مطلوبہ بنیادی Supabase جدولیں اور بنیادی RLS ڈھانچہ۔

3) README_اردو.txt
   یہ وضاحت۔

اہم بات:
اصل Supabase URL اور ANON KEY مجھے دستیاب مواد میں نہیں ملے، اس لیے میں نے کوئی جعلی یا غلط رابطہ نہیں ڈالا۔
index.html کے شروع میں:
SUPABASE_URL
SUPABASE_ANON_KEY
میں آپ کے اپنے موجودہ Supabase منصوبے کی values لگانی ہوں گی۔

یہی آخری ضروری کنکشن ہے۔ اس کے بغیر GitHub Pages فائل کسی Database سے جڑ نہیں سکتی۔

Admin:
Supabase Auth میں مالک کا اکاؤنٹ بنایا جائے گا، پھر profiles میں اسی user UUID کو owner role دیا جائے گا۔

Customer:
Customer کو Admin Login نہیں دکھایا جاتا۔ عام صفحہ Tracking/QR کے لیے ہے۔

Technician:
Technician اپنے Auth اکاؤنٹ سے Login کر سکتا ہے اور activity/role کے مطابق اندرونی حصے تک رسائی دی جا سکتی ہے۔

Visit Log:
activity_logs میں اندرونی صارف کے module visits محفوظ کیے جاتے ہیں۔

QR:
QR کے اندر Tracking URL یا Tracking Code آنے کی صورت میں scanner code نکال کر record تلاش کرتا ہے۔

نوٹ:
میں نے جان بوجھ کر “100% tested” یا “بغیر کسی configuration کے مکمل live” کا دعویٰ نہیں کیا، کیونکہ اصل Supabase credentials/schema میرے پاس موجود نہیں تھے۔ غلط credential ڈالنا اس منصوبے کو مزید خراب کرتا۔
