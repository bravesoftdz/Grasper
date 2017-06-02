<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Records
 */
class Records
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var integer
     */
    private $num;

    /**
     * @var string
     */
    private $key;

    /**
     * @var string
     */
    private $value;

    /**
     * @var string
     */
    private $valueHash;

    /**
     * @var \PIA\appBundle\Entity\Links
     */
    private $link;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set num
     *
     * @param integer $num
     * @return Records
     */
    public function setNum($num)
    {
        $this->num = $num;

        return $this;
    }

    /**
     * Get num
     *
     * @return integer 
     */
    public function getNum()
    {
        return $this->num;
    }

    /**
     * Set key
     *
     * @param string $key
     * @return Records
     */
    public function setKey($key)
    {
        $this->key = $key;

        return $this;
    }

    /**
     * Get key
     *
     * @return string 
     */
    public function getKey()
    {
        return $this->key;
    }

    /**
     * Set value
     *
     * @param string $value
     * @return Records
     */
    public function setValue($value)
    {
        $this->value = $value;

        return $this;
    }

    /**
     * Get value
     *
     * @return string 
     */
    public function getValue()
    {
        return $this->value;
    }

    /**
     * Set valueHash
     *
     * @param string $valueHash
     * @return Records
     */
    public function setValueHash($valueHash)
    {
        $this->valueHash = $valueHash;

        return $this;
    }

    /**
     * Get valueHash
     *
     * @return string 
     */
    public function getValueHash()
    {
        return $this->valueHash;
    }

    /**
     * Set link
     *
     * @param \PIA\appBundle\Entity\Links $link
     * @return Records
     */
    public function setLink(\PIA\appBundle\Entity\Links $link = null)
    {
        $this->link = $link;

        return $this;
    }

    /**
     * Get link
     *
     * @return \PIA\appBundle\Entity\Links 
     */
    public function getLink()
    {
        return $this->link;
    }
}
