import React from "react";
import { Calendar, momentLocalizer } from "react-big-calendar";
import "react-big-calendar/lib/css/react-big-calendar.css";
import moment from "moment";

const localizer = momentLocalizer(moment);

const BigCalendar = (props) => <Calendar localizer={localizer} {...props} />;

export default BigCalendar;
