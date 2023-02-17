from xhtml2pdf import pisa


def get_pdf(order_number, receipt, image_file):

    result_file = open(f"output/{order_number}.pdf", "w+b")
    html_string = f"""{receipt}"""
    html_string += f"""<br/><div style="text-align:center;"><img src="{image_file}" height="600" style="text-align:center;"></div>"""

    pisa_status = pisa.CreatePDF(
            html_string,                
            dest=result_file)           

    result_file.close()                 


