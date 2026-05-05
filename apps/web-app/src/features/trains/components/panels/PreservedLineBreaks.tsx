function PreservedLineBreaks(props: { value: string }) {
  return (
    <>
      {props.value.split(/\r?\n/).map((line, index) => (
        <span key={index}>
          {index > 0 && <br />}
          {line}
        </span>
      ))}
    </>
  );
}

export default PreservedLineBreaks;
