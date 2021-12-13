import java.text.SimpleDateFormat

def call() {
    date = new Date()
    sdate = new SimpleDateFormat("yyy-MM-dd")
    Calendar cal = Calendar.getInstance()
                
    if(params.BuildDate == "today") {
        dateValue = sdate.format(date)
    } else {
        dateValue = params.BuildDate
    }
    echo dateValue

    return dateValue
}
