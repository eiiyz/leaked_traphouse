function addGaps(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + '<span style="margin-left: 3px; margin-right: 3px;"/>' + '$2');
  }
  return x1 + x2;
}
function addCommas(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',<span style="margin-left: 0px; margin-right: 1px;"/>' + '$2');
  }
  return x1 + x2;
} 





function openContainer(id)
{
  var trapId = id;
  $("#wrap").css("display", "block");
$( "#PINcode" ).html(
  "<form action='' method='' name='PINform' id='PINform' autocomplete='off' draggable='true'>" +
    "<input id='PINbox' type='password' value='' name='PINbox' disabled />" +
    "<input id='TRAPid' type='hidden' value="+trapId+" name='TRAPid' />" +
    "<br/>" +
    "<input type='button' class='PINbutton' name='1' value='1' id='1' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='2' value='2' id='2' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='3' value='3' id='3' onClick=addNumber(this); />" +
    "<br>" +
    "<input type='button' class='PINbutton' name='4' value='4' id='4' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='5' value='5' id='5' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='6' value='6' id='6' onClick=addNumber(this); />" +
    "<br>" +
    "<input type='button' class='PINbutton' name='7' value='7' id='7' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='8' value='8' id='8' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton' name='9' value='9' id='9' onClick=addNumber(this); />" +
    "<br>" +
    "<input type='button' class='PINbutton' name='0' value='0' id='0' onClick=addNumber(this); />" +
    "<input type='button' class='PINbutton enter' name='+' value='enter' id='+' onClick=submitForm(PINbox); />" +
    "<input type='button' class='PINbutton clear' name='-' value='clear' id='-' onClick=clearForm(this); />" +
  "</form>"
);

}

function closeContainer()
{
  $("#wrap").css("display", "none");
}

window.addEventListener('message', function(event){
  var item = event.data;

  if(item.open === true) {
    openContainer(item.id)
  }
  if(item.close === true) {
    closeContainer()
  }
});

let keys = [1,2,3,4,5,6,7,8,9,0]

document.onkeyup = function (data) {
  if (data.which == 27 ) {
    $.post('http://cfx_traphouse/close', JSON.stringify({}));
  } else if (data.which == 13 ) {
    /*$.post('http://cfx_traphouse/complete', JSON.stringify({ 
      pin: $( "#PINbox" ).val(),
      id: $("#TRAPid").val()
    }));
    */
  } else {
    if ( !isNaN(data.key) ) {
      var v = $( "#PINbox" ).val();
      $( "#PINbox" ).val( v + data.key );
    }
  }
};


function addNumber(e){
  //document.getElementById('PINbox').value = document.getElementById('PINbox').value+element.value;
  var v = $( "#PINbox" ).val();
  $( "#PINbox" ).val( v + e.value );
}
function clearForm(e){
  //document.getElementById('PINbox').value = "";
  $( "#PINbox" ).val( "" );
}
function submitForm(e, id) {
  if (e.value == "") {

  } else {
    $.post('http://cfx_traphouse/complete', JSON.stringify({ 
      pin:e.value,
      id: $("#TRAPid").val()
    }));
    data = {
      pin: e.value,
      id: $("#TRAPid").val()
    }
    /*    
    apiCall( data, function( r ) {
      $( "#logo" ).attr( "src", r.site_logo );
      $( ".title-msg" ).text( r.site_msg );
      accent = r.accent;
      $( ".accent-bg" ).css( "background-color", accent );
    });
    */
    
    //document.getElementById('PINbox').value = "";
    $( "#PINbox" ).val( "" );
  };
};

