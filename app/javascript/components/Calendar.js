import React, { useState } from "react";

import { Views } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";

import BigCalendar from "./BigCalendar";

const parseEvents = (events) =>
  events.map((event) => {
    const { start, end, id, title } = event;

    return {
      allData: event,
      start: moment(start).toDate(),
      end: moment(end).toDate(),
      id,
      title,
    };
  });

const Calendar = ({ events }) => {
  const [allEvents, setAllEvents] = useState(parseEvents(events))

  return (
    <div>
      <h1> It's about time. </h1>
      <BigCalendar
        selectable
        events={allEvents}
        defaultView={Views.WEEK}
        views={{ week: true, month: true }}
        showMultiDayTimes
        popup
        defaultDate={new Date()}
        onSelectSlot={(e) => {}}
        onSelectEvent={(e) => {}}
      />
    </div>
  );
};

export default Calendar;
