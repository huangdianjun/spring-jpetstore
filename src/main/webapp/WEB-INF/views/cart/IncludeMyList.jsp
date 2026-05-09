<sec:authorize access="isAuthenticated()">
    <p>
        Pet Favorites <br /> Shop for more of your favorite pets here.
    </p>
    <ul>
        <sec:authentication property="principal.myList" var="products" />
        <c:forEach var="product" items="${products}">
            <li><a
                href="${pageContext.request.contextPath}/catalog/viewProduct?productId=${fn:escapeXml(product.productId)}">
                    ${fn:escapeXml(product.name)} </a>(${fn:escapeXml(product.productId)})</li>
        </c:forEach>
    </ul>
</sec:authorize>
